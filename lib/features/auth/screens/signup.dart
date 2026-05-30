import 'package:flutter/material.dart';
import 'package:smartops/core/validators/auth_validators.dart';


import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import '../widgets/role_selector.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String selectedRole = 'Admin';
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isLoading = false;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signup validation successful')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
              title: 'Create Account',
              subtitle: 'Register to start using SmartOps',
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: fullNameController,
              prefixIcon: Icons.person_outline,
              validator: AuthValidators.fullName,
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 18),
            RoleSelector(
              selectedRole: selectedRole,
              onChanged: (role) {
                setState(() => selectedRole = role);
              },
            ),
            const SizedBox(height: 18),
            AppTextField(
              label: 'Password',
              hint: 'Create a password',
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
            const SizedBox(height: 18),
            AppTextField(
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
              validator: (value) => AuthValidators.confirmPassword(
                value,
                passwordController.text,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Create Account',
              icon: Icons.arrow_forward,
              isLoading: isLoading,
              onPressed: signup,
            ),
            const SizedBox(height: 16),
            AppFooter(
              text: 'Already have an account?',
              actionText: 'Login',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}