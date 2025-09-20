import '../repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for toggling user availability status
/// Encapsulates the business logic for changing user availability
class ToggleUserAvailabilityUseCase {
  final ProfileRepository repository;

  const ToggleUserAvailabilityUseCase(this.repository);

  /// Execute the use case to toggle user availability
  ///
  /// Returns the new availability status on success
  /// Returns a Failure on error
  Future<Either<Failure, bool>> call() async {
    try {
      // Get current availability status
      final currentStatusResult = await repository.getUserAvailabilityStatus();

      return currentStatusResult.fold(
        (failure) => Left(failure),
        (currentStatus) async {
          // Toggle the status
          final newStatus = !currentStatus;

          // Update the availability status
          final updateResult = await repository.toggleUserAvailability(newStatus);

          return updateResult.fold(
            (failure) => Left(failure),
            (updatedStatus) => Right(updatedStatus),
          );
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to toggle user availability: ${e.toString()}'));
    }
  }

  /// Set specific availability status
  Future<Either<Failure, bool>> setAvailability(bool isAvailable) async {
    try {
      final result = await repository.toggleUserAvailability(isAvailable);
      return result;
    } catch (e) {
      return Left(ServerFailure('Failed to set user availability: ${e.toString()}'));
    }
  }
}

/// Use case for getting current user availability status
class GetUserAvailabilityUseCase {
  final ProfileRepository repository;

  const GetUserAvailabilityUseCase(this.repository);

  /// Execute the use case to get current availability
  Future<Either<Failure, bool>> call() async {
    try {
      return await repository.getUserAvailabilityStatus();
    } catch (e) {
      return Left(ServerFailure('Failed to get user availability: ${e.toString()}'));
    }
  }
}