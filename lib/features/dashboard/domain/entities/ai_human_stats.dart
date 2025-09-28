class Advisor {
  final String name;
  final int conversationCount;

  const Advisor({
    required this.name,
    required this.conversationCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Advisor &&
        other.name == name &&
        other.conversationCount == conversationCount;
  }

  @override
  int get hashCode => name.hashCode ^ conversationCount.hashCode;

  @override
  String toString() => 'Advisor(name: $name, conversationCount: $conversationCount)';
}

class ConversationBreakdown {
  final int count;
  final double percentage;

  const ConversationBreakdown({
    required this.count,
    required this.percentage,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversationBreakdown &&
        other.count == count &&
        other.percentage == percentage;
  }

  @override
  int get hashCode => count.hashCode ^ percentage.hashCode;

  @override
  String toString() => 'ConversationBreakdown(count: $count, percentage: $percentage)';
}

class AiHumanStats {
  final int totalConversations;
  final ConversationBreakdown aiOnly;
  final ConversationBreakdown humanAssisted;
  final List<Advisor> advisors;

  const AiHumanStats({
    required this.totalConversations,
    required this.aiOnly,
    required this.humanAssisted,
    required this.advisors,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AiHumanStats &&
        other.totalConversations == totalConversations &&
        other.aiOnly == aiOnly &&
        other.humanAssisted == humanAssisted;
  }

  @override
  int get hashCode {
    return totalConversations.hashCode ^
        aiOnly.hashCode ^
        humanAssisted.hashCode;
  }

  @override
  String toString() {
    return 'AiHumanStats(totalConversations: $totalConversations, aiOnly: $aiOnly, humanAssisted: $humanAssisted)';
  }
}