import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/internal_notes_remote_datasource.dart';
import '../../domain/entities/internal_note_entity.dart';

enum InternalNotesStatus { initial, loading, loaded, loadingMore, error }

/// Internal Notes Provider
///
/// Manages state for internal notes in a conversation.
class InternalNotesProvider extends ChangeNotifier {
  final InternalNotesRemoteDataSource _dataSource;

  InternalNotesProvider(this._dataSource);

  // State
  InternalNotesStatus _status = InternalNotesStatus.initial;
  String? _errorMessage;
  List<InternalNoteEntity> _notes = [];
  int _totalCount = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;
  int? _currentConversationId;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Getters
  InternalNotesStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<InternalNoteEntity> get notes => _notes;
  int get totalCount => _totalCount;
  bool get hasMore => _currentPage < _totalPages;
  bool get isLoading => _status == InternalNotesStatus.loading;
  bool get isLoadingMore => _status == InternalNotesStatus.loadingMore;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

  /// Load internal notes for a conversation
  Future<void> loadNotes(int conversationId, {bool resetPage = false}) async {
    if (resetPage || _currentConversationId != conversationId) {
      _currentPage = 1;
      _notes = [];
      _currentConversationId = conversationId;
      _status = InternalNotesStatus.loading;
    } else {
      _status = InternalNotesStatus.loadingMore;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dataSource.getInternalNotes(
        conversationId: conversationId,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (_currentPage == 1) {
        _notes = response.notes;
      } else {
        _notes = [..._notes, ...response.notes];
      }

      _totalCount = response.totalCount;
      _totalPages = response.totalPages;
      _status = InternalNotesStatus.loaded;

      AppLogger.info('Loaded ${response.notes.length} internal notes (page $_currentPage)');
    } catch (e, stackTrace) {
      AppLogger.error('Error loading internal notes', error: e, stackTrace: stackTrace);
      _status = InternalNotesStatus.error;
      _errorMessage = 'error_loading_notes';
    }

    notifyListeners();
  }

  /// Load more notes (pagination)
  Future<void> loadMoreNotes() async {
    if (_currentConversationId == null || !hasMore || isLoadingMore) return;

    _currentPage++;
    await loadNotes(_currentConversationId!);
  }

  /// Create a new note
  Future<bool> createNote(int conversationId, String content) async {
    _isCreating = true;
    notifyListeners();

    try {
      final newNote = await _dataSource.createNote(
        conversationId: conversationId,
        content: content,
      );

      // Add to the beginning of the list
      _notes = [newNote, ..._notes];
      _totalCount++;

      AppLogger.info('Created internal note: ${newNote.id}');
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error creating internal note', error: e, stackTrace: stackTrace);
      _errorMessage = 'error_creating_note';
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing note
  Future<bool> updateNote(int conversationId, int noteId, String content) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final updatedNote = await _dataSource.updateNote(
        conversationId: conversationId,
        noteId: noteId,
        content: content,
      );

      // Update in list
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes = [
          ..._notes.sublist(0, index),
          updatedNote,
          ..._notes.sublist(index + 1),
        ];
      }

      AppLogger.info('Updated internal note: $noteId');
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating internal note', error: e, stackTrace: stackTrace);
      _errorMessage = 'error_updating_note';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a note
  Future<bool> deleteNote(int conversationId, int noteId) async {
    _isDeleting = true;
    notifyListeners();

    try {
      await _dataSource.deleteNote(
        conversationId: conversationId,
        noteId: noteId,
      );

      // Remove from list
      _notes = _notes.where((n) => n.id != noteId).toList();
      if (_totalCount > 0) _totalCount--;

      AppLogger.info('Deleted internal note: $noteId');
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting internal note', error: e, stackTrace: stackTrace);
      _errorMessage = 'error_deleting_note';
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear state
  void clear() {
    _status = InternalNotesStatus.initial;
    _errorMessage = null;
    _notes = [];
    _totalCount = 0;
    _currentPage = 1;
    _totalPages = 1;
    _currentConversationId = null;
    notifyListeners();
  }
}
