import 'package:flutter/material.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_rules.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthHeader(
            title: 'Reset password',
            subtitle: 'Create a new secure password for your account',
          ),

          const SizedBox(height: 30),

          AuthTextField(
            label: 'New Password',
            hint: 'Enter new password',
            controller: passwordController,
            obscureText: isPasswordHidden,
            prefixIcon: Icons.lock_outline,
            suffixIcon: isPasswordHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onSuffixTap: () {
              setState(() {
                isPasswordHidden = !isPasswordHidden;
              });
            },
          ),

          const SizedBox(height: 14),

          const PasswordRules(),

          const SizedBox(height: 18),

          AuthTextField(
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
          ),

          const SizedBox(height: 28),

          AuthButton(
            text: 'Reset Password',
            icon: Icons.check,
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}