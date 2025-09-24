class AuthValidation {
  // Email validation
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmedEmail = email.trim();
    if (!_isValidEmail(trimmedEmail)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }

    final trimmedName = name.trim();
    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (trimmedName.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check if name contains only letters, spaces, and common punctuation
    if (!RegExp(r"^[a-zA-Z\s\-\.\']+$").hasMatch(trimmedName)) {
      return 'Name can only contain letters, spaces, hyphens, periods, and apostrophes';
    }

    return null;
  }

  // Phone number validation (basic)
  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return null; // Optional field
    }

    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]+'), '');

    if (cleanedNumber.length < 10 || cleanedNumber.length > 15) {
      return 'Please enter a valid phone number';
    }

    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanedNumber)) {
      return 'Phone number can only contain numbers and an optional + prefix';
    }

    return null;
  }

  // Organization name validation
  static String? validateOrganizationName(String? orgName) {
    if (orgName == null || orgName.trim().isEmpty) {
      return null; // Optional field
    }

    final trimmedName = orgName.trim();
    if (trimmedName.length < 2) {
      return 'Organization name must be at least 2 characters long';
    }

    if (trimmedName.length > 100) {
      return 'Organization name must be less than 100 characters';
    }

    return null;
  }

  // Check password strength
  static PasswordStrength getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    int score = 0;

    // Length
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;

    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) score += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 1;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 1;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  // Private helper methods
  static bool _isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    ).hasMatch(email);
  }

  // Normalize email
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Normalize name
  static String normalizeName(String name) {
    return name.trim().split(' ').where((word) => word.isNotEmpty).join(' ');
  }

  // Check if field has valid input
  static bool hasValidInput(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // Multi-field validation
  static Map<String, String?> validateLoginForm({
    required String? email,
    required String? password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
    };
  }

  static Map<String, String?> validateResetPasswordForm({
    required String? email,
  }) {
    return {
      'email': validateEmail(email),
    };
  }

  // Form validation helper
  static bool isFormValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  // Extract first error from validation results
  static String? getFirstError(Map<String, String?> validationResults) {
    for (final error in validationResults.values) {
      if (error != null) return error;
    }
    return null;
  }
}

enum PasswordStrength {
  none,
  weak,
  medium,
  strong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}