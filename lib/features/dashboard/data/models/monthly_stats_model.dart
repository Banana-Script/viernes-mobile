import 'dart:convert';
import '../../domain/entities/monthly_stats.dart';

class MonthlyStatsModel extends MonthlyStats {
  const MonthlyStatsModel({
    required super.interactions,
    required super.attendees,
    required super.sentiments,
    required super.topCategories,
    required super.tags,
    required super.aiOnlyConversations,
    required super.humanAssistedConversations,
    required super.aiPercentage,
    required super.humanPercentage,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    // Parse sentiments from JSON string
    Map<String, int> parsedSentiments = {};
    if (json['sentiments'] != null && json['sentiments'].isNotEmpty) {
      try {
        final sentimentsData = json['sentiments'] is String
            ? jsonDecode(json['sentiments'])
            : json['sentiments'];
        if (sentimentsData is Map) {
          parsedSentiments = Map<String, int>.from(
            sentimentsData.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0))
          );
        }
      } catch (e) {
        parsedSentiments = {};
      }
    }

    // Parse top_categories from JSON string
    Map<String, int> parsedCategories = {};
    if (json['top_categories'] != null && json['top_categories'].isNotEmpty) {
      try {
        final categoriesData = json['top_categories'] is String
            ? jsonDecode(json['top_categories'])
            : json['top_categories'];
        if (categoriesData is Map) {
          parsedCategories = Map<String, int>.from(
            categoriesData.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0))
          );
        }
      } catch (e) {
        parsedCategories = {};
      }
    }

    // Parse tags from JSON string
    Map<String, int> parsedTags = {};
    if (json['tags'] != null && json['tags'].isNotEmpty) {
      try {
        final tagsData = json['tags'] is String
            ? jsonDecode(json['tags'])
            : json['tags'];
        if (tagsData is Map) {
          parsedTags = Map<String, int>.from(
            tagsData.map((key, value) => MapEntry(key.toString(), int.tryParse(value.toString()) ?? 0))
          );
        }
      } catch (e) {
        parsedTags = {};
      }
    }

    return MonthlyStatsModel(
      interactions: json['interactions'] ?? 0,
      attendees: json['attendees'] ?? 0,
      sentiments: parsedSentiments,
      topCategories: parsedCategories,
      tags: parsedTags,
      aiOnlyConversations: json['ai_only_conversations'] ?? 0,
      humanAssistedConversations: json['human_assisted_conversations'] ?? 0,
      aiPercentage: (json['ai_percentage'] ?? 0.0).toDouble(),
      humanPercentage: (json['human_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interactions': interactions,
      'attendees': attendees,
      'sentiments': jsonEncode(sentiments),
      'top_categories': jsonEncode(topCategories),
      'tags': jsonEncode(tags),
      'ai_only_conversations': aiOnlyConversations,
      'human_assisted_conversations': humanAssistedConversations,
      'ai_percentage': aiPercentage,
      'human_percentage': humanPercentage,
    };
  }

  MonthlyStats toEntity() {
    return MonthlyStats(
      interactions: interactions,
      attendees: attendees,
      sentiments: sentiments,
      topCategories: topCategories,
      tags: tags,
      aiOnlyConversations: aiOnlyConversations,
      humanAssistedConversations: humanAssistedConversations,
      aiPercentage: aiPercentage,
      humanPercentage: humanPercentage,
    );
  }
}