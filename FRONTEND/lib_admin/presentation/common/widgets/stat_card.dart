import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? sub;

  /// نسبة الاتجاه (مثلاً 12 يعني +12%) — اختياري
  final num? trendValue;

  /// اتجاه إيجابي/سلبي للّون والسهم
  final bool? trendIsPositive;

  /// عرض حالة تحميل (skeleton بسيط)
  final bool isLoading;

  /// حدث الضغط على الكارت
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.sub,
    this.trendValue,
    this.trendIsPositive,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trend = (trendValue != null && trendIsPositive != null)
        ? _TrendChip(
            value: trendValue!,
            isPositive: trendIsPositive!,
          )
        : const SizedBox.shrink();

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFFA7A7A7), fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    trend,
                  ],
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!,
                      style: const TextStyle(
                          color: Color(0xFFA7A7A7), fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: isLoading
          ? _Skeleton()
          : (onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: content,
                )),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final num value;
  final bool isPositive;
  const _TrendChip({required this.value, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? Colors.greenAccent : Colors.redAccent;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final sign = isPositive ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$sign${value.toString()}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _box(const Size(42, 42)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(const Size(120, 12)),
                  const SizedBox(height: 8),
                  _box(const Size(160, 18)),
                  const SizedBox(height: 6),
                  _box(const Size(100, 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(Size s) {
    return Container(
      width: s.width,
      height: s.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
