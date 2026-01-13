/// Customer Entity
///
/// Domain entity representing a customer in the organization.
/// This entity is used in the customers list view.
class CustomerEntity {
  final int id;
  final int userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? identification;
  final int? age;
  final String? occupation;
  final DateTime createdAt;
  final String? segment;
  final String? segmentSummary;
  final String? segmentDescription;
  final DateTime? segmentDate;
  final DateTime? lastInteraction;
  final List<InsightInfo> insightsInfo;
  final AssignedAgent? assignedAgent;
  final LastConversation? lastConversation;

  const CustomerEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.identification,
    this.age,
    this.occupation,
    required this.createdAt,
    this.segment,
    this.segmentSummary,
    this.segmentDescription,
    this.segmentDate,
    this.lastInteraction,
    this.insightsInfo = const [],
    this.assignedAgent,
    this.lastConversation,
  });

  /// Get purchase intention level from insights
  String? get purchaseIntention {
    try {
      final insight = insightsInfo.firstWhere(
        (i) => i.feature == 'purchase_intention',
      );
      return insight.value;
    } catch (e) {
      return null;
    }
  }

  /// Check if customer has an active conversation
  bool get hasActiveConversation {
    return lastConversation != null && lastConversation!.locked;
  }
}

/// Insight Information
///
/// Represents customer insights/analytics data
class InsightInfo {
  final String feature;
  final String? value;

  const InsightInfo({
    required this.feature,
    this.value,
  });
}

/// Assigned Agent
///
/// Represents the agent assigned to a customer
class AssignedAgent {
  final int id;
  final String name;
  final String email;

  const AssignedAgent({
    required this.id,
    required this.name,
    required this.email,
  });
}

/// Last Conversation
///
/// Represents the last conversation with the customer
class LastConversation {
  final int id;
  final bool readed;
  final bool locked;
  final DateTime? updatedAt;

  const LastConversation({
    required this.id,
    required this.readed,
    required this.locked,
    this.updatedAt,
  });

  /// Check if conversation is within 24h window for direct chat
  ///
  /// Returns true only if:
  /// - Not locked
  /// - Has updatedAt timestamp
  /// - updatedAt is within last 24 hours
  ///
  /// This matches the frontend's isTemplateSelectionNeeded logic.
  bool get canDirectChat {
    if (locked) return false;
    if (updatedAt == null) return false;

    final now = DateTime.now().toUtc();
    final lastUpdate = updatedAt!.toUtc();
    final diffInHours = now.difference(lastUpdate).inHours;
    return diffInHours < 24;
  }
}
