import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';

/// Abstraction the domain layer depends on. The data layer provides the
/// concrete implementation; the UI never sees the implementation details.
abstract class ProfileRepository {
  /// Returns the current user's profile.
  ///
  /// Remote-first; on a network failure it falls back to the last cached value,
  /// returning a [NetworkFailure] only when neither source is available.
  Future<Result<UserProfile, Failure>> getProfile();
}
