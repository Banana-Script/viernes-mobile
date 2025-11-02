import '../../features/customers/domain/entities/customer_entity.dart';
import 'insight_parser.dart';

/// Customer Insight Helper Utility
///
/// Provides centralized methods for extracting and parsing customer insight values.
/// Eliminates code duplication across multiple widgets.
///
/// Usage:
/// ```dart
/// final summary = CustomerInsightHelper.getInsightValue(customer, 'summary_profile');
/// // or using extension method:
/// final summary = customer.getInsight('summary_profile');
/// ```
class CustomerInsightHelper {
  /// Get parsed insight value for a specific feature
  ///
  /// Parameters:
  /// - [customer]: The customer entity containing insights
  /// - [feature]: The insight feature name to retrieve
  /// - [languageCode]: Optional language code (defaults to 'en')
  ///
  /// Returns:
  /// - Parsed insight value as a string, or empty string if not found
  static String getInsightValue(
    CustomerEntity customer,
    String feature, {
    String? languageCode,
  }) {
    try {
      final insight = customer.insightsInfo.firstWhere(
        (i) => i.feature == feature,
      );

      if (insight.value == null) return '';

      return InsightParser.parse(
        insight.value,
        languageCode: languageCode ?? 'en',
      );
    } catch (e) {
      // Feature not found or parsing error
      return '';
    }
  }

  /// Get multiple insight values at once
  ///
  /// Useful when you need to retrieve several insights together
  static Map<String, String> getInsightValues(
    CustomerEntity customer,
    List<String> features, {
    String? languageCode,
  }) {
    final results = <String, String>{};
    for (final feature in features) {
      results[feature] = getInsightValue(
        customer,
        feature,
        languageCode: languageCode,
      );
    }
    return results;
  }

  /// Check if a customer has a specific insight feature
  static bool hasInsight(CustomerEntity customer, String feature) {
    try {
      customer.insightsInfo.firstWhere((i) => i.feature == feature);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Extension methods for convenient access to customer insights
///
/// Allows calling insights directly on CustomerEntity:
/// ```dart
/// final summary = customer.getInsight('summary_profile');
/// final hasSummary = customer.hasInsight('summary_profile');
/// ```
extension CustomerInsightExtension on CustomerEntity {
  /// Get parsed insight value for a specific feature
  String getInsight(String feature, {String languageCode = 'en'}) {
    return CustomerInsightHelper.getInsightValue(
      this,
      feature,
      languageCode: languageCode,
    );
  }

  /// Check if this customer has a specific insight
  bool hasInsight(String feature) {
    return CustomerInsightHelper.hasInsight(this, feature);
  }

  /// Get multiple insights at once
  Map<String, String> getInsights(List<String> features, {String languageCode = 'en'}) {
    return CustomerInsightHelper.getInsightValues(
      this,
      features,
      languageCode: languageCode,
    );
  }
}
