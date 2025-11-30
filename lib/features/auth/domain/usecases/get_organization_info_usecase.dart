import '../entities/organization_entity.dart';
import '../repositories/user_repository.dart';

class GetOrganizationInfoUseCase {
  final UserRepository _repository;

  GetOrganizationInfoUseCase(this._repository);

  /// Fetches the organization info for the logged user
  Future<OrganizationEntity> call() async {
    return await _repository.getOrganizationInfo();
  }
}
