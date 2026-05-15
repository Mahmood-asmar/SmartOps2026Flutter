import 'package:flutter/material.dart';
import 'package:smartops/features/auth/screens/forgetpass.dart';
import 'package:smartops/features/auth/screens/signup.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    String? errorMessage;
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please fill in all fields.';
    } else if (!email.contains('@') || !email.contains('.')) {
      errorMessage = 'Please enter a valid email address.';
    } else if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters.';
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Signed in as $email.')));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        children: [
          const AuthHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to continue to SmartOps',
          ),

          const SizedBox(height: 32),

          AuthTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 18),

          AuthTextField(
            label: 'Password',
            hint: 'Enter your password',
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

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ForgetPassScreen()),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          AuthButton(
            text: 'Login',
            icon: Icons.arrow_forward,
            onPressed: _login,
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don’t have an account?",
                style: TextStyle(color: Color(0xFF5F6C7B)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
