import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_integration.freezed.dart';
part 'conversation_integration.g.dart';

@freezed
class ConversationIntegration with _$ConversationIntegration {
  const factory ConversationIntegration({
    required int id,
    required String name,
    required String type,
  }) = _ConversationIntegration;

  factory ConversationIntegration.fromJson(Map<String, dynamic> json) =>
      _$ConversationIntegrationFromJson(json);
}