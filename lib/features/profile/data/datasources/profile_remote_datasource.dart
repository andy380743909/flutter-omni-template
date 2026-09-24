import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/network/http_client.dart';
import 'package:app_template/features/profile/data/models/profile_model.dart';

/// Remote boundary for the profile feature.
///
/// Talks to the [HttpClient] abstraction (never [dio] directly). Low-level
/// conditions are surfaced as [AppException]s for the repository to translate.
abstract class ProfileRemoteDataSource {
  /// Fetches the current user's profile from the API.
  Future<ProfileModel> getProfile();
}

/// [ProfileRemoteDataSource] backed by the [HttpClient] abstraction.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final HttpClient httpClient;

  const ProfileRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final Map<String, dynamic> json = await httpClient.get('/profile');
      return ProfileModel.fromJson(json);
    } on FormatException catch (e) {
      throw ServerException(message: 'Invalid profile response: $e');
    } catch (e) {
      // The HttpClient may surface transport errors (e.g. a DioException) that
      // are not AppExceptions; normalize them to a NetworkException.
      throw NetworkException(message: 'Failed to fetch profile: $e');
    }
  }
}
