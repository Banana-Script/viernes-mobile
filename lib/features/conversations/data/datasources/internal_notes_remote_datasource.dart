import 'package:dio/dio.dart';
import '../../../../core/services/http_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/internal_note_model.dart';

/// Internal Notes Remote Data Source
///
/// Handles all HTTP requests related to internal notes.
abstract class InternalNotesRemoteDataSource {
  /// Get internal notes for a conversation
  Future<InternalNotesResponseModel> getInternalNotes({
    required int conversationId,
    required int page,
    required int pageSize,
  });

  /// Create a new internal note
  Future<InternalNoteModel> createNote({
    required int conversationId,
    required String content,
  });

  /// Update an existing internal note
  Future<InternalNoteModel> updateNote({
    required int conversationId,
    required int noteId,
    required String content,
  });

  /// Delete an internal note
  Future<void> deleteNote({
    required int conversationId,
    required int noteId,
  });
}

/// Internal Notes Remote Data Source Implementation
class InternalNotesRemoteDataSourceImpl implements InternalNotesRemoteDataSource {
  final HttpClient _httpClient;

  InternalNotesRemoteDataSourceImpl(this._httpClient);

  @override
  Future<InternalNotesResponseModel> getInternalNotes({
    required int conversationId,
    required int page,
    required int pageSize,
  }) async {
    final endpoint = '/conversations/$conversationId/internal_notes';

    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      AppLogger.apiRequest('GET', endpoint, params: queryParams);

      final response = await _httpClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        return InternalNotesResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw NetworkException(
          'Failed to load internal notes',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        // Return empty notes if not found
        return const InternalNotesResponseModel(
          notes: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching internal notes',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing internal notes response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<InternalNoteModel> createNote({
    required int conversationId,
    required String content,
  }) async {
    final endpoint = '/conversations/$conversationId/internal_notes';

    try {
      final requestData = {
        'content': content,
      };

      AppLogger.apiRequest('POST', endpoint, params: requestData);

      final response = await _httpClient.dio.post(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InternalNoteModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to create internal note',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid note content',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Conversation not found',
          resourceType: 'Conversation',
          resourceId: conversationId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while creating note',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing create note response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<InternalNoteModel> updateNote({
    required int conversationId,
    required int noteId,
    required String content,
  }) async {
    final endpoint = '/conversations/$conversationId/internal_notes/$noteId';

    try {
      final requestData = {
        'content': content,
      };

      AppLogger.apiRequest('PUT', endpoint, params: requestData);

      final response = await _httpClient.dio.put(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        return InternalNoteModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to update internal note',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid note content',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Note not found',
          resourceType: 'InternalNote',
          resourceId: noteId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while updating note',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing update note response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteNote({
    required int conversationId,
    required int noteId,
  }) async {
    final endpoint = '/conversations/$conversationId/internal_notes/$noteId';

    try {
      AppLogger.apiRequest('DELETE', endpoint);

      final response = await _httpClient.dio.delete(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          'Failed to delete internal note',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Note not found',
          resourceType: 'InternalNote',
          resourceId: noteId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while deleting note',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      if (e is NotFoundException || e is UnauthorizedException) rethrow;
      throw NetworkException(
        'Error deleting note: ${e.toString()}',
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }
}
