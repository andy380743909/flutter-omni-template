import 'package:app_template/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_template/features/profile/data/models/profile_model.dart';

/// In-memory mock implementation of [ProfileRemoteDataSource].
///
/// Returns a fixed sample profile so the UI always has content even when the
/// real backend is unreachable. Useful for demos and offline previews.
class ProfileMockDataSource implements ProfileRemoteDataSource {
  const ProfileMockDataSource();

  @override
  Future<ProfileModel> getProfile() async {
    // Simulate a short network round-trip so the loading state is exercised.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const ProfileModel(
      id: 'u_1001',
      name: 'Cui Panjun',
      email: 'cui.panjun@example.com',
      avatarUrl: null,
    );
  }
}
