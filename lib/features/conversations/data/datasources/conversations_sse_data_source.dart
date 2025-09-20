import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/sse_events_model.dart';

abstract class ConversationsSSEDataSource {
  Stream<SSEEventModel> getConversationSSEStream(
    int conversationId,
    String token,
  );
}

class ConversationsSSEDataSourceImpl implements ConversationsSSEDataSource {
  final http.Client _httpClient;

  ConversationsSSEDataSourceImpl(this._httpClient);

  @override
  Stream<SSEEventModel> getConversationSSEStream(
    int conversationId,
    String token,
  ) async* {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/sse/conversation/$conversationId?token=${Uri.encodeComponent(token)}',
    );

    final request = http.Request('GET', uri);
    request.headers.addAll({
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
    });

    try {
      final streamedResponse = await _httpClient.send(request);

      if (streamedResponse.statusCode != 200) {
        throw ServerException(
          'SSE connection failed with status: ${streamedResponse.statusCode}',
        );
      }

      await for (final chunk in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {

        if (chunk.isEmpty) continue;

        // Parse SSE format: "data: {json}"
        if (chunk.startsWith('data: ')) {
          final jsonStr = chunk.substring(6);

          if (jsonStr.trim().isEmpty) continue;

          try {
            final jsonData = json.decode(jsonStr);
            final event = SSEEventModel.fromJson(jsonData);
            yield event;
          } catch (e) {
            // Skip malformed events in production, log in debug
            assert(() {
              // ignore: avoid_print
              print('Failed to parse SSE event: $e, data: $jsonStr');
              return true;
            }());
          }
        }
      }
    } catch (e) {
      throw ServerException('SSE connection error: $e');
    }
  }
}