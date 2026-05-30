import 'package:flutter/material.dart';
import 'package:smartops/core/validators/auth_validators.dart';


import 'package:smartops/core/widgets/app_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import '../widgets/password_rules.dart';
import 'login.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isLoading = false;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successfully')),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
              title: 'Reset Password',
              subtitle: 'Create a new secure password for your account',
            ),
            const SizedBox(height: 30),
            AppTextField(
              label: 'New Password',
              hint: 'Enter new password',
              controller: passwordController,
              obscureText: isPasswordHidden,
              prefixIcon: Icons.lock_outline,
              suffixIcon: isPasswordHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () {
                setState(() => isPasswordHidden = !isPasswordHidden);
              },
              validator: AuthValidators.password,
            ),
            const SizedBox(height: 14),
            const PasswordRules(),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Confirm Password',
              hint: 'Confirm new password',
              controller: confirmPasswordController,
              obscureText: isConfirmPasswordHidden,
              prefixIcon: Icons.lock_outline,
              suffixIcon: isConfirmPasswordHidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () {
                setState(() {
                  isConfirmPasswordHidden = !isConfirmPasswordHidden;
                });
              },
              validator: (value) => AuthValidators.confirmPassword(
                value,
                passwordController.text,
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Reset Password',
              icon: Icons.check,
              isLoading: isLoading,
              onPressed: resetPassword,
            ),
          ],
        ),
      ),
    );
  }
}