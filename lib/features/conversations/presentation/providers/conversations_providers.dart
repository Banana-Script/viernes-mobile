import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/conversations_remote_data_source.dart';
import '../../data/datasources/conversations_sse_data_source.dart';
import '../../data/repositories/conversations_repository_impl.dart';
import '../../domain/repositories/conversations_repository.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_conversation_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/manage_conversation.dart';
import '../../domain/usecases/listen_to_sse_events.dart';

// Data Source Providers
final conversationsRemoteDataSourceProvider = Provider<ConversationsRemoteDataSource>((ref) {
  return ConversationsRemoteDataSourceImpl(DioClient.instance);
});

final conversationsSSEDataSourceProvider = Provider<ConversationsSSEDataSource>((ref) {
  return ConversationsSSEDataSourceImpl(http.Client());
});

// Repository Provider
final conversationsRepositoryProvider = Provider<ConversationsRepository>((ref) {
  return ConversationsRepositoryImpl(
    ref.watch(conversationsRemoteDataSourceProvider),
    ref.watch(conversationsSSEDataSourceProvider),
  );
});

// Use Case Providers
final getConversationsUseCaseProvider = Provider<GetConversations>((ref) {
  return GetConversations(ref.watch(conversationsRepositoryProvider));
});

final getAllConversationsUseCaseProvider = Provider<GetAllConversations>((ref) {
  return GetAllConversations(ref.watch(conversationsRepositoryProvider));
});

final getMyConversationsUseCaseProvider = Provider<GetMyConversations>((ref) {
  return GetMyConversations(ref.watch(conversationsRepositoryProvider));
});

final getViernesConversationsUseCaseProvider = Provider<GetViernesConversations>((ref) {
  return GetViernesConversations(ref.watch(conversationsRepositoryProvider));
});

final getConversationByIdUseCaseProvider = Provider<GetConversationById>((ref) {
  return GetConversationById(ref.watch(conversationsRepositoryProvider));
});

final getConversationMessagesUseCaseProvider = Provider<GetConversationMessages>((ref) {
  return GetConversationMessages(ref.watch(conversationsRepositoryProvider));
});

final getPreviousConversationMessagesUseCaseProvider = Provider<GetPreviousConversationMessages>((ref) {
  return GetPreviousConversationMessages(ref.watch(conversationsRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(conversationsRepositoryProvider));
});

final updateConversationStatusUseCaseProvider = Provider<UpdateConversationStatus>((ref) {
  return UpdateConversationStatus(ref.watch(conversationsRepositoryProvider));
});

final assignConversationUseCaseProvider = Provider<AssignConversation>((ref) {
  return AssignConversation(ref.watch(conversationsRepositoryProvider));
});

final assignConversationWithReopenUseCaseProvider = Provider<AssignConversationWithReopen>((ref) {
  return AssignConversationWithReopen(ref.watch(conversationsRepositoryProvider));
});

final reassignConversationUseCaseProvider = Provider<ReassignConversation>((ref) {
  return ReassignConversation(ref.watch(conversationsRepositoryProvider));
});

final checkUserAvailabilityUseCaseProvider = Provider<CheckUserAvailability>((ref) {
  return CheckUserAvailability(ref.watch(conversationsRepositoryProvider));
});

final listenToSSEEventsUseCaseProvider = Provider<ListenToSSEEvents>((ref) {
  return ListenToSSEEvents(ref.watch(conversationsRepositoryProvider));
});