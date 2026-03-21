import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFFEDEDED),
            ),
          ),
        ),
      ),
    );
  }
}