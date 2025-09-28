class MonthlyStats {
  final int interactions;
  final int attendees;
  final Map<String, int> sentiments;
  final Map<String, int> topCategories;
  final Map<String, int> tags;
  final int aiOnlyConversations;
  final int humanAssistedConversations;
  final double aiPercentage;
  final double humanPercentage;

  const MonthlyStats({
    required this.interactions,
    required this.attendees,
    required this.sentiments,
    required this.topCategories,
    required this.tags,
    required this.aiOnlyConversations,
    required this.humanAssistedConversations,
    required this.aiPercentage,
    required this.humanPercentage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MonthlyStats &&
        other.interactions == interactions &&
        other.attendees == attendees &&
        other.aiOnlyConversations == aiOnlyConversations &&
        other.humanAssistedConversations == humanAssistedConversations &&
        other.aiPercentage == aiPercentage &&
        other.humanPercentage == humanPercentage;
  }

  @override
  int get hashCode {
    return interactions.hashCode ^
        attendees.hashCode ^
        aiOnlyConversations.hashCode ^
        humanAssistedConversations.hashCode ^
        aiPercentage.hashCode ^
        humanPercentage.hashCode;
  }

  @override
  String toString() {
    return 'MonthlyStats(interactions: $interactions, attendees: $attendees, aiOnlyConversations: $aiOnlyConversations, humanAssistedConversations: $humanAssistedConversations, aiPercentage: $aiPercentage, humanPercentage: $humanPercentage)';
  }
}