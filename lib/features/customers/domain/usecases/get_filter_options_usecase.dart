import '../repositories/customer_repository.dart';

/// Get Filter Options Use Case
///
/// Retrieves all available filter options for the customer list.
/// This includes owners/agents, segments, and purchase intentions.
class GetFilterOptionsUseCase {
  final CustomerRepository _repository;

  GetFilterOptionsUseCase(this._repository);

  /// Get available owners/agents for filtering
  Future<List<Map<String, dynamic>>> getOwners() async {
    return await _repository.getOwners();
  }

  /// Get available segments for filtering
  Future<List<String>> getSegments() async {
    return await _repository.getSegments();
  }

  /// Get purchase intentions statistics
  Future<Map<String, int>> getPurchaseIntentions() async {
    return await _repository.getPurchaseIntentions();
  }
}
