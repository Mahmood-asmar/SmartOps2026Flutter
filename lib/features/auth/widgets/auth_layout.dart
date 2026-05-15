import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final Widget? footer;

  const AuthLayout({
    super.key,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  child,
                  const SizedBox(height: 24),
                  if (footer != null) ...[
                    footer!,
                    const SizedBox(height: 24),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}