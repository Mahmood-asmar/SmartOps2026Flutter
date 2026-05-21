import 'package:flutter/material.dart';
import 'package:smartops/core/validators/auth_validators.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import 'forgetpass.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
    isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login validation successful'),
      ),
    );

    // TODO: later navigate to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const AuthHeader(
              title: 'Welcome Back',
              subtitle: 'Access your dashboard.',
            ),

            const SizedBox(height: 32),

            AuthTextField(
              label: 'Email Address',
              hint: 'name@company.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: AuthValidators.email,
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
              validator: AuthValidators.password,
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgetPassScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot?',
                  style: TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            AuthButton(
              text: 'Sign Into Dashboard',
              icon: Icons.arrow_forward,
              isLoading: isLoading,
              onPressed: login,
            ),

            const SizedBox(height: 24),

            AuthFooter(
              text: 'New to SmartOps?',
              actionText: 'Create an account',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}