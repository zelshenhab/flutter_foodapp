import 'dart:async';

import 'package:flutter/material.dart';

enum AppToastType { error, success, info }

/// Top sliding toast matching the dark + gold app design.
class AppToast {
  static OverlayEntry? _entry;

  static void error(BuildContext context, String message) {
    show(context, message, type: AppToastType.error);
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: AppToastType.success);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: AppToastType.info);
  }

  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.error,
    Duration duration = const Duration(seconds: 3),
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopToastHost(
        message: text,
        type: type,
        duration: duration,
        onDismiss: dismiss,
      ),
    );

    _entry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }
}

class _TopToastHost extends StatefulWidget {
  const _TopToastHost({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_TopToastHost> createState() => _TopToastHostState();
}

class _TopToastHostState extends State<_TopToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoClose;
  bool _closing = false;

  static const _accent = Color.fromARGB(255, 199, 160, 34);
  static const _text = Color(0xFFEDEDED);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.forward();
    _autoClose = Timer(widget.duration, _close);
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_closing || !mounted) return;
    _closing = true;
    _autoClose?.cancel();
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  Color get _iconColor {
    switch (widget.type) {
      case AppToastType.error:
        return const Color(0xFFFF6B6B);
      case AppToastType.success:
        return const Color(0xFF4CAF50);
      case AppToastType.info:
        return _accent;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppToastType.error:
        return Icons.error_outline_rounded;
      case AppToastType.success:
        return Icons.check_circle_outline_rounded;
      case AppToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  Color get _glow {
    switch (widget.type) {
      case AppToastType.error:
        return const Color(0xFFFF6B6B).withValues(alpha: 0.18);
      case AppToastType.success:
        return const Color(0xFF4CAF50).withValues(alpha: 0.18);
      case AppToastType.info:
        return _accent.withValues(alpha: 0.18);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, top + 8, 16, 0),
              child: GestureDetector(
                onTap: _close,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -80) {
                    _close();
                  }
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                    boxShadow: [
                      BoxShadow(
                        color: _glow,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _glow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_icon, color: _iconColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _close,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFFA7A7A7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
