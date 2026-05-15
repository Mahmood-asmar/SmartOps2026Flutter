import 'package:flutter/material.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/otp_input.dart';
import 'resetpass.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthHeader(
            title: 'Verify OTP',
            subtitle: 'Enter the 4-digit code sent to your email',
          ),

          const SizedBox(height: 36),

          OtpInput(controllers: otpControllers),

          const SizedBox(height: 28),

          AuthButton(
            text: 'Verify Code',
            icon: Icons.arrow_forward,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPassScreen()),
              );
            },
          ),

          const SizedBox(height: 18),

          Center(
            child: TextButton(
              onPressed: () {
                for (final controller in otpControllers) {
                  controller.clear();
                }
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification code resent.')),
                );
              },
              child: const Text(
                'Resend Code',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
