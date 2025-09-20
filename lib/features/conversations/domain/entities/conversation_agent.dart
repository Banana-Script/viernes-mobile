import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_agent.freezed.dart';
part 'conversation_agent.g.dart';

@freezed
class ConversationAgent with _$ConversationAgent {
  const factory ConversationAgent({
    required int id,
    required String fullname,
    required String email,
  }) = _ConversationAgent;

  factory ConversationAgent.fromJson(Map<String, dynamic> json) =>
      _$ConversationAgentFromJson(json);
}