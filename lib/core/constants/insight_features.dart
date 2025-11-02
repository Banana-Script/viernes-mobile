/// Insight Feature Constants
///
/// Centralized string constants for all insight feature names.
/// Used to eliminate magic strings and ensure consistency across the app.
///
/// These constants correspond to the `feature` field in InsightInfo entities
/// from the customer insights API.
///
/// Usage:
/// ```dart
/// final summary = customer.getInsight(InsightFeatures.summaryProfile);
/// ```
class InsightFeatures {
  // Private constructor to prevent instantiation
  InsightFeatures._();

  // ==================== PROFILE & SUMMARY ====================

  /// Customer profile summary
  /// Contains high-level overview of the customer
  static const String summaryProfile = 'summary_profile';

  /// Detailed insights about the customer
  /// More detailed analysis than summary_profile
  static const String insights = 'insights';

  // ==================== SENTIMENT ANALYSIS ====================

  /// Sentiment analysis result (Positive/Negative/Neutral)
  static const String sentimentAnalysis = 'sentiment_analysis';

  /// Detailed explanation of sentiment analysis
  static const String sentimentAnalysisDetail = 'sentiment_analysis_detail';

  // ==================== ATTITUDE ANALYSIS ====================

  /// Attitude analysis result
  static const String attitudeAnalysis = 'attitude_analysis';

  /// Detailed explanation of attitude analysis
  static const String attitudeAnalysisDetails = 'attitude_analysis_details';

  // ==================== PERSONALITY ANALYSIS ====================

  /// Personality analysis result
  static const String personalityAnalysis = 'personality_analysis';

  /// Detailed explanation of personality analysis
  static const String personalityAnalysisDetails = 'personality_analysis_details';

  // ==================== INTENTIONS ANALYSIS ====================

  /// Customer intentions analysis result
  static const String intentionsAnalysis = 'intentions_analysis';

  /// Detailed explanation of intentions analysis
  static const String intentionsAnalysisDetails = 'intentions_analysis_details';

  // ==================== PURCHASE BEHAVIOR ====================

  /// Purchase intention level (High/Medium/Low)
  static const String purchaseIntention = 'purchase_intention';

  /// Main topic of interest for the customer
  static const String mainInterest = 'main_interest';

  /// Other topics the customer has shown interest in
  static const String otherTopics = 'other_topics';

  // ==================== NET PROMOTER SCORE ====================

  /// Net Promoter Score value (0-10)
  static const String nps = 'nps';

  /// Alternative field name for Net Promoter Score
  static const String netPromoterScore = 'net_promoter_score';

  // ==================== INTERACTION METRICS ====================

  /// Number of interactions per month
  static const String interactionsPerMonth = 'interactions_per_month';

  /// Reasons for last interactions
  static const String lastInteractionsReason = 'last_interactions_reason';

  /// Suggested actions to take with this customer
  static const String actionsToCall = 'actions_to_call';

  // ==================== HELPER METHODS ====================

  /// Get all insight feature names as a list
  static List<String> get allFeatures => [
        summaryProfile,
        insights,
        sentimentAnalysis,
        sentimentAnalysisDetail,
        attitudeAnalysis,
        attitudeAnalysisDetails,
        personalityAnalysis,
        personalityAnalysisDetails,
        intentionsAnalysis,
        intentionsAnalysisDetails,
        purchaseIntention,
        mainInterest,
        otherTopics,
        nps,
        netPromoterScore,
        interactionsPerMonth,
        lastInteractionsReason,
        actionsToCall,
      ];

  /// Get all sentiment-related features
  static List<String> get sentimentFeatures => [
        sentimentAnalysis,
        sentimentAnalysisDetail,
        attitudeAnalysis,
        attitudeAnalysisDetails,
        personalityAnalysis,
        personalityAnalysisDetails,
        intentionsAnalysis,
        intentionsAnalysisDetails,
      ];

  /// Get all interaction-related features
  static List<String> get interactionFeatures => [
        interactionsPerMonth,
        lastInteractionsReason,
        actionsToCall,
      ];

  /// Get all purchase-related features
  static List<String> get purchaseFeatures => [
        purchaseIntention,
        mainInterest,
        otherTopics,
      ];
}
