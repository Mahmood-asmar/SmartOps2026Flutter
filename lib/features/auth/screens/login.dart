import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/validators/auth_validators.dart';


import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import 'forgetpass.dart';
import 'signup.dart';
import 'package:smartops/features//dashboard/screens/dashboard_screen.dart';


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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: Colors.green,
        ),
      );

      // TODO: هون بعدين بنوديه على صفحة Dashboard/Home لما تبعتلي اسمها.
      // مثال:
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (_) => const DashboardScreen()),
       );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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

            AppTextField(
              label: 'Email Address',
              hint: 'name@company.com',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: AuthValidators.email,
            ),

            const SizedBox(height: 18),

            AppTextField(
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
                onPressed: authProvider.isLoading
                    ? null
                    : () {
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

            AppButton(
              text: 'Sign Into Dashboard',
              icon: Icons.arrow_forward,
              isLoading: authProvider.isLoading,
              onPressed: login,
            ),

            const SizedBox(height: 24),

            AppFooter(
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
