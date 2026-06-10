import 'package:flutter/material.dart';

import 'package:smartops/core/services/user_service.dart';
import 'package:smartops/core/widgets/app_button.dart';

class AddUserSheet extends StatefulWidget {
  final VoidCallback onUserCreated;

  const AddUserSheet({
    super.key,
    required this.onUserCreated,
  });

  @override
  State<AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<AddUserSheet> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'employee';
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Name is required';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (name.length > 100) {
      return 'Name must be less than 100 characters';
    }

    final nameRegex = RegExp(r"^[A-Za-z\u0600-\u06FF\s.'-]+$");

    if (!nameRegex.hasMatch(name)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    if (email.length > 120) {
      return 'Email must be less than 120 characters';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (password.length > 100) {
      return 'Password must be less than 100 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';
    final password = passwordController.text.trim();

    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _createUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await UserService.createUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole,
      );

      if (!mounted) return;

      Navigator.pop(context);

      widget.onUserCreated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF253B56),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF667085),
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFE8EBEF),
            hintStyle: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorMaxLines: 2,
            errorStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0B2E59) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0B2E59)
                  : const Color(0xFFE9EEF5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF0B2E59),
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0B2E59),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD RULES',
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 8),
          _RuleRow(text: 'At least 8 characters'),
          _RuleRow(text: 'Numbers only are allowed'),
          _RuleRow(text: 'Letters only are allowed'),
          _RuleRow(text: 'Password and confirm password must match'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EEF8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: Color(0xFF0B2E59),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add User',
                              style: TextStyle(
                                color: Color(0xFF0B2E59),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Create secure admin, employee, or client accounts.',
                              style: TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _buildTextField(
                    label: 'Full Name',
                    controller: nameController,
                    icon: Icons.person_outline,
                    validator: _validateName,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Password',
                    controller: passwordController,
                    icon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF667085),
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    label: 'Confirm Password',
                    controller: confirmPasswordController,
                    icon: Icons.lock_reset_outlined,
                    obscureText: obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF667085),
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 14),

                  _buildPasswordRules(),

                  const SizedBox(height: 18),

                  const Text(
                    'ROLE',
                    style: TextStyle(
                      color: Color(0xFF253B56),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildRoleOption(
                        role: 'employee',
                        title: 'Employee',
                        icon: Icons.engineering_outlined,
                      ),
                      const SizedBox(width: 10),
                      _buildRoleOption(
                        role: 'admin',
                        title: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                      ),
                      const SizedBox(width: 10),
                      _buildRoleOption(
                        role: 'client',
                        title: 'Client',
                        icon: Icons.person_outline,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  AppButton(
                    text: isLoading ? 'Creating...' : 'Create User',
                    icon: Icons.person_add_alt_1_outlined,
                    isLoading: isLoading,
                    onPressed: _createUser,
                  ),

                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Center(
                      child: Text(
                        'Cancel',
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
          ),
        );
      },
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String text;

  const _RuleRow({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade700,
            size: 15,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}