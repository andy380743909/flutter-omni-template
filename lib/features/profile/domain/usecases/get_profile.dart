import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/domain/repositories/profile_repository.dart';

/// Use case: read the current user's profile.
class GetProfile implements UseCase<UserProfile, NoParams> {
  final ProfileRepository repository;

  const GetProfile({required this.repository});

  @override
  Future<Result<UserProfile, Failure>> call(NoParams params) =>
      repository.getProfile();
}
