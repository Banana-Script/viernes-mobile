import '../repositories/user_repository.dart';

class ChangeAgentAvailabilityUseCase {
  final UserRepository _repository;

  ChangeAgentAvailabilityUseCase(this._repository);

  /// Changes the agent's availability status
  /// isAvailable: true to set as active (010), false to set as inactive (020)
  ///
  /// Note: This use case relies on the repository having cached the current user
  /// from a previous getUserProfile call to get the user ID.
  Future<void> call(bool isAvailable) async {
    return await _repository.changeAgentAvailability(isAvailable);
  }
}
