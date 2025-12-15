import '../../domain/entities/ai_human_stats.dart';

class AdvisorModel extends Advisor {
  const AdvisorModel({
    required super.name,
    required super.conversationCount,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      name: json['advisor_name'] ?? json['name'] ?? '',
      conversationCount: json['conversation_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'conversation_count': conversationCount,
    };
  }

  Advisor toEntity() {
    return Advisor(
      name: name,
      conversationCount: conversationCount,
    );
  }
}

class ConversationBreakdownModel extends ConversationBreakdown {
  const ConversationBreakdownModel({
    required super.count,
    required super.percentage,
  });

  factory ConversationBreakdownModel.fromJson(Map<String, dynamic> json) {
    return ConversationBreakdownModel(
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'percentage': percentage,
    };
  }

  ConversationBreakdown toEntity() {
    return ConversationBreakdown(
      count: count,
      percentage: percentage,
    );
  }
}

class AiHumanStatsModel extends AiHumanStats {
  const AiHumanStatsModel({
    required super.totalConversations,
    required super.aiOnly,
    required super.humanAssisted,
    required super.advisors,
  });

  factory AiHumanStatsModel.fromJson(Map<String, dynamic> json) {
    // API wraps response in 'data' object
    final data = json['data'] as Map<String, dynamic>? ?? json;

    // Parse advisors breakdown
    List<AdvisorModel> advisorsList = [];
    if (data['advisors_breakdown'] != null &&
        data['advisors_breakdown']['advisors'] != null) {
      final advisorsData = data['advisors_breakdown']['advisors'] as List;
      advisorsList = advisorsData
          .map((advisor) => AdvisorModel.fromJson(advisor))
          .toList();
    }

    return AiHumanStatsModel(
      totalConversations: data['total_conversations'] ?? 0,
      aiOnly: ConversationBreakdownModel.fromJson(data['ai_only'] ?? {}),
      humanAssisted: ConversationBreakdownModel.fromJson(data['human_assisted'] ?? {}),
      advisors: advisorsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_conversations': totalConversations,
      'ai_only': (aiOnly as ConversationBreakdownModel).toJson(),
      'human_assisted': (humanAssisted as ConversationBreakdownModel).toJson(),
      'advisors_breakdown': {
        'advisors': advisors.map((advisor) => (advisor as AdvisorModel).toJson()).toList(),
      },
    };
  }

  AiHumanStats toEntity() {
    return AiHumanStats(
      totalConversations: totalConversations,
      aiOnly: aiOnly,
      humanAssisted: humanAssisted,
      advisors: advisors,
    );
  }
}