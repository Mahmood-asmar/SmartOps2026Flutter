import 'package:flutter/material.dart';
import 'package:smartops/core/validators/auth_validators.dart';


import 'package:smartops/core/widgets/app_button.dart';
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
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());

  bool isLoading = false;
  String? otpError;

  @override
  void dispose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get otpCode {
    return otpControllers.map((controller) => controller.text).join();
  }

  Future<void> verifyOtp() async {
    final error = AuthValidators.otp(otpCode);

    if (error != null) {
      setState(() => otpError = error);
      return;
    }

    setState(() {
      otpError = null;
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPassScreen()),
    );
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
          if (otpError != null) ...[
            const SizedBox(height: 8),
            Text(
              otpError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 28),
          AppButton(
            text: 'Verify Code',
            icon: Icons.arrow_forward,
            isLoading: isLoading,
            onPressed: verifyOtp,
          ),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code resent successfully')),
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