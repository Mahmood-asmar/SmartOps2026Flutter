import 'package:flutter/material.dart';
import 'package:smartops/features/auth/screen/login.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String selectedRole = 'Admin';
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    String? errorMessage;
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      errorMessage = 'Please fill in all fields.';
    } else if (!email.contains('@') || !email.contains('.')) {
      errorMessage = 'Please enter a valid email address.';
    } else if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters.';
    } else if (password != confirmPassword) {
      errorMessage = 'Passwords do not match.';
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account initialized for $fullName.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthHeader(
            title: 'Create account',
            subtitle: 'Register to start using SmartOps',
          ),

          const SizedBox(height: 28),

          AuthTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: fullNameController,
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 18),

          AuthTextField(
            label: 'Email',
            hint: 'name@gmail.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 18),

          RoleSelector(
            selectedRole: selectedRole,
            onChanged: (role) {
              setState(() {
                selectedRole = role;
              });
            },
          ),

          const SizedBox(height: 18),

          AuthTextField(
            label: 'Password',
            hint: 'Create a password',
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

          const SizedBox(height: 18),

          AuthTextField(
            label: 'Confirm Password',
            hint: 'Confirm your password',
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

          const SizedBox(height: 24),

          AuthButton(
            text: 'Initialize Account',
            icon: Icons.arrow_forward,
            onPressed: _register,
          ),

          const SizedBox(height: 16),

          AuthFooter(
            text: 'Already part of SmartOps?',
            actionText: 'Login',
            onTap: () {
              Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(
                   builder: (_) => const LoginScreen(),
                 ),
              );
            },
          ),
        ],
      ),
    );
  }
}
