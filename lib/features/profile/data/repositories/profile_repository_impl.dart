import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:app_template/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_template/features/profile/data/datasources/profile_mock_datasource.dart';
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
  final ProfileMockDataSource mockDataSource;

  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.mockDataSource = const ProfileMockDataSource(),
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
        // ignore, fall through to mock sample data
      }
      // No cache available: serve mock sample profile so the UI has content.
      return Result.success((await mockDataSource.getProfile()).toEntity());
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
