import 'package:flutter/material.dart';
import 'package:smartops/core/validators/auth_validators.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import 'otp.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OtpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(
              title: 'Forgot Password?',
              subtitle: 'Enter your email to receive a verification code',
            ),
            const SizedBox(height: 32),
            AuthTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 28),
            AuthButton(
              text: 'Send Code',
              icon: Icons.arrow_forward,
              isLoading: isLoading,
              onPressed: sendCode,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}