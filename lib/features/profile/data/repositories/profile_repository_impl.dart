import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:app_template/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_template/features/profile/data/models/profile_model.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/domain/repositories/profile_repository.dart';

/// Concrete [ProfileRepository]: remote-first with a local cache fallback.
///
/// Catches low-level [AppException]s and converts them into domain [Failure]s,
/// never leaking implementation details above the data layer.
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<UserProfile, Failure>> getProfile() async {
    try {
      final ProfileModel model = await remoteDataSource.getProfile();
      await localDataSource.cacheProfile(model);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } on NetworkException {
      // Offline: fall back to the last cached profile when available.
      try {
        final ProfileModel? cached = await localDataSource.getLastProfile();
        if (cached != null) {
          return Result.success(cached.toEntity());
        }
      } on CacheException {
        // ignore, fall through to a network failure
      }
      return Result.failure(
        NetworkFailure(message: 'No network and no cached profile.'),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
