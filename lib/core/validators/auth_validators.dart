class AuthValidators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? fullName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Full name is required';
  }

  if (value.trim().length < 3) {
    return 'Full name must be at least 3 characters';
  }

  final nameRegex = RegExp(r'^[a-zA-Z\s]+$');

  if (!nameRegex.hasMatch(value.trim())) {
    return 'Full name must contain letters only';
  }

  return null;
 }

  static String? otp(String code) {
    if (code.length != 4) {
      return 'Please enter the 4-digit code';
    }

    return null;
  }
}