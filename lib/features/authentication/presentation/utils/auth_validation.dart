import '../../../../l10n/app_localizations.dart';

/// Comprehensive validation utilities for authentication forms
/// Provides consistent validation across all authentication screens
class AuthValidation {
  // Email validation pattern - comprehensive RFC compliant regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  // Password strength patterns
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasNumbers = RegExp(r'[0-9]');
  static final RegExp _hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Validates email address
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterEmail;
    }

    final email = value.trim();
    if (!_emailRegex.hasMatch(email)) {
      return l10n.pleaseEnterValidEmail;
    }

    // Additional email length check
    if (email.length > 254) {
      return l10n.invalidEmailFormat;
    }

    return null;
  }

  /// Validates password with strength requirements
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value, AppLocalizations l10n, {bool requireStrong = false}) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseEnterPassword;
    }

    if (value.length < 6) {
      return l10n.passwordTooShort;
    }

    // For registration, require stronger passwords
    if (requireStrong) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters long';
      }

      if (!_hasLowercase.hasMatch(value)) {
        return 'Password must contain lowercase letters';
      }

      if (!_hasUppercase.hasMatch(value)) {
        return 'Password must contain uppercase letters';
      }

      if (!_hasNumbers.hasMatch(value)) {
        return 'Password must contain numbers';
      }

      // Optional: Special characters requirement
      // if (!_hasSpecialCharacters.hasMatch(value)) {
      //   return 'Password must contain special characters';
      // }
    }

    return null;
  }

  /// Validates password confirmation
  /// Returns null if valid, error message if invalid
  static String? validatePasswordConfirmation(
    String? value,
    String? originalPassword,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseConfirmPassword;
    }

    if (value != originalPassword) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }

  /// Validates full name
  /// Returns null if valid, error message if invalid
  static String? validateFullName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterName;
    }

    final name = value.trim();
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (name.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-'\.]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  /// Validates first name
  /// Returns null if valid, error message if invalid
  static String? validateFirstName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterFirstName;
    }

    final name = value.trim();
    if (name.length < 2) {
      return 'First name must be at least 2 characters long';
    }

    if (name.length > 30) {
      return 'First name must be less than 30 characters';
    }

    // Check for valid name characters
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-'\.]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'First name contains invalid characters';
    }

    return null;
  }

  /// Validates last name
  /// Returns null if valid, error message if invalid
  static String? validateLastName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterLastName;
    }

    final name = value.trim();
    if (name.length < 2) {
      return 'Last name must be at least 2 characters long';
    }

    if (name.length > 30) {
      return 'Last name must be less than 30 characters';
    }

    // Check for valid name characters
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-'\.]+$");
    if (!nameRegex.hasMatch(name)) {
      return 'Last name contains invalid characters';
    }

    return null;
  }

  /// Validates terms acceptance
  /// Returns null if valid, error message if invalid
  static String? validateTermsAcceptance(bool? accepted, AppLocalizations l10n) {
    if (accepted != true) {
      return l10n.pleaseAcceptTerms;
    }
    return null;
  }

  /// Get password strength level (0-4)
  /// 0: Very weak, 1: Weak, 2: Fair, 3: Good, 4: Strong
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (_hasLowercase.hasMatch(password)) strength++;
    if (_hasUppercase.hasMatch(password)) strength++;
    if (_hasNumbers.hasMatch(password)) strength++;
    if (_hasSpecialCharacters.hasMatch(password)) strength++;

    return strength > 4 ? 4 : strength;
  }

  /// Get password strength description
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very weak';
    }
  }

  /// Get password strength color
  static String getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'red';
      case 2:
        return 'orange';
      case 3:
        return 'yellow';
      case 4:
      case 5:
        return 'green';
      default:
        return 'red';
    }
  }

  /// Sanitize input by trimming whitespace
  static String sanitizeInput(String input) {
    return input.trim();
  }

  /// Check if email domain is commonly used (for better UX suggestions)
  static bool isCommonEmailDomain(String email) {
    final domain = email.split('@').last.toLowerCase();
    const commonDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com',
      'aol.com',
      'msn.com',
      'live.com',
    ];
    return commonDomains.contains(domain);
  }

  /// Suggest email correction for common typos
  static String? suggestEmailCorrection(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return null;

    final domain = parts[1].toLowerCase();

    // Common typo corrections
    const corrections = {
      'gmail.co': 'gmail.com',
      'gmail.cm': 'gmail.com',
      'gmai.com': 'gmail.com',
      'yahoo.co': 'yahoo.com',
      'yahoo.cm': 'yahoo.com',
      'hotmail.co': 'hotmail.com',
      'hotmail.cm': 'hotmail.com',
      'outlook.co': 'outlook.com',
      'outlook.cm': 'outlook.com',
    };

    if (corrections.containsKey(domain)) {
      return '${parts[0]}@${corrections[domain]}';
    }

    return null;
  }
}