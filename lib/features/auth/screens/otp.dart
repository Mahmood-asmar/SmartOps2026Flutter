import 'package:flutter/material.dart';
import 'package:smartops/core/local_storage/auth_storage.dart';
import 'package:smartops/core/services/auth_service.dart';

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
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  bool isLoading = false;
  bool isResending = false;
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

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> verifyOtp() async {
    setState(() => otpError = null);

    final email = await AuthStorage.getResetEmail();

    if (email == null || email.isEmpty) {
      setState(() {
        otpError = 'Email not found. Please request a new code.';
      });
      return;
    }

    if (otpCode.length != 6) {
      setState(() {
        otpError = 'OTP must be 6 digits';
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService.verifyOtp(
        email: email,
        otp: otpCode,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetPassScreen()),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        otpError = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> resendCode() async {
    setState(() => otpError = null);

    final email = await AuthStorage.getResetEmail();

    if (email == null || email.isEmpty) {
      setState(() {
        otpError = 'Email not found. Please request a new code.';
      });
      return;
    }

    setState(() => isResending = true);

    try {
      await AuthService.forgotPassword(email: email);

      for (final controller in otpControllers) {
        controller.clear();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        otpError = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthHeader(
            title: 'Verify OTP',
            subtitle: 'Enter the 6-digit code sent to your email',
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

          AuthButton(
            text: 'Verify Code',
            icon: Icons.arrow_forward,
            isLoading: isLoading,
            onPressed: isResending ? null : verifyOtp,
          ),

          const SizedBox(height: 18),

          Center(
            child: TextButton(
              onPressed: isLoading || isResending ? null : resendCode,
              child: Text(
                isResending ? 'Resending...' : 'Resend Code',
                style: const TextStyle(
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