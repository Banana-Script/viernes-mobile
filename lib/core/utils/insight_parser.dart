import 'dart:convert';

/// Insight Parser Utility
///
/// Parses multilingual insight JSON strings and extracts values.
/// Used throughout the customer detail page for parsing insight data.
///
/// Example Input:
/// ```json
/// {
///   "es": "Alta intención de compra",
///   "en": "High purchase intention"
/// }
/// ```
///
/// Output: "High purchase intention" (for 'en' locale)
class InsightParser {
  /// Parse insight JSON string and extract value for the specified language
  ///
  /// Parameters:
  /// - [jsonString]: JSON string containing multilingual insights
  /// - [languageCode]: Language code (default: 'en')
  ///
  /// Returns:
  /// - Parsed string for the specified language, or fallback to first available,
  ///   or the original string if parsing fails
  static String parse(String? jsonString, {String languageCode = 'en'}) {
    if (jsonString == null || jsonString.isEmpty) {
      return '';
    }

    // Try to parse as JSON
    try {
      final Map<String, dynamic> parsed = json.decode(jsonString);

      // Try to get the requested language
      if (parsed.containsKey(languageCode)) {
        return parsed[languageCode].toString();
      }

      // Fallback to English
      if (parsed.containsKey('en')) {
        return parsed['en'].toString();
      }

      // Fallback to Spanish
      if (parsed.containsKey('es')) {
        return parsed['es'].toString();
      }

      // Fallback to first available value
      if (parsed.isNotEmpty) {
        return parsed.values.first.toString();
      }

      // If JSON is empty, return empty string
      return '';
    } catch (e) {
      // If parsing fails, return the original string
      // (it might be a plain string, not JSON)
      return jsonString;
    }
  }

  /// Parse list of insights from JSON string
  ///
  /// Used for parsing array insights like interests or tags
  static List<String> parseList(String? jsonString, {String languageCode = 'en'}) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final dynamic parsed = json.decode(jsonString);

      if (parsed is List) {
        // If it's a list of strings, return directly
        if (parsed.isNotEmpty && parsed.first is String) {
          return parsed.cast<String>();
        }

        // If it's a list of objects, extract the language value
        return parsed.map((item) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey(languageCode)) {
              return item[languageCode].toString();
            }
            if (item.containsKey('en')) {
              return item['en'].toString();
            }
            if (item.containsKey('es')) {
              return item['es'].toString();
            }
            return item.values.first.toString();
          }
          return item.toString();
        }).toList();
      }

      return [];
    } catch (e) {
      // If parsing fails, try to split by comma
      return jsonString.split(',').map((s) => s.trim()).toList();
    }
  }

  /// Check if a string is a valid JSON
  static bool isValidJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return false;
    }

    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all available languages from a multilingual JSON
  static List<String> getAvailableLanguages(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final Map<String, dynamic> parsed = json.decode(jsonString);
      return parsed.keys.toList();
    } catch (e) {
      return [];
    }
  }
}
