/// Form field validators
///
/// Provides reusable validation functions for common input types
class Validators {
  /// Email validation
  ///
  /// Returns error message if invalid, null if valid
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu email';
    }

    final emailRegex = RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Por favor ingresa un email válido';
    }

    return null;
  }

  /// Password validation (basic)
  ///
  /// Returns error message if invalid, null if valid
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Password validation (strong)
  ///
  /// Requires at least 8 characters with uppercase, lowercase, and numbers
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Debe contener mayúsculas, minúsculas y números';
    }

    return null;
  }

  /// Confirm password validation
  ///
  /// Returns error message if passwords don't match, null if valid
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Por favor confirma tu contraseña';
      }

      if (value != originalPassword) {
        return 'Las contraseñas no coinciden';
      }

      return null;
    };
  }

  /// Required field validation
  ///
  /// Returns error message if empty, null if valid
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Minimum length validation
  ///
  /// Returns error message if too short, null if valid
  static String? Function(String?) minLength(int length, [String? customMessage]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Use required validator for empty check
      }

      if (value.length < length) {
        return customMessage ?? 'Debe tener al menos $length caracteres';
      }

      return null;
    };
  }

  /// Maximum length validation
  ///
  /// Returns error message if too long, null if valid
  static String? Function(String?) maxLength(int length, [String? customMessage]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (value.length > length) {
        return customMessage ?? 'Debe tener máximo $length caracteres';
      }

      return null;
    };
  }

  /// Combine multiple validators
  ///
  /// Returns first error found, or null if all pass
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
