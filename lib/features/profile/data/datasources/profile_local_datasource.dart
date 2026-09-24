import 'dart:convert';

import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/storage/key_value_storage.dart';
import 'package:app_template/features/profile/data/models/profile_model.dart';

/// Local cache boundary for the profile feature.
///
/// Persists the last successfully fetched profile so the UI can render something
/// while offline. Low-level failures become [CacheException]s.
abstract class ProfileLocalDataSource {
  /// Returns the last cached profile, or `null` when none exists.
  Future<ProfileModel?> getLastProfile();

  /// Caches a profile for offline use.
  Future<void> cacheProfile(ProfileModel model);
}

/// [ProfileLocalDataSource] backed by [KeyValueStorage].
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _storageKey = 'profile';

  final KeyValueStorage storage;

  const ProfileLocalDataSourceImpl({required this.storage});

  @override
  Future<ProfileModel?> getLastProfile() async {
    try {
      final String? raw = await storage.readString(key: _storageKey);
      if (raw == null) return null;
      return ProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException(message: 'Failed to read cached profile: $e');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel model) async {
    try {
      final bool ok = await storage.writeString(
        key: _storageKey,
        value: jsonEncode(model.toJson()),
      );
      if (!ok) {
        throw const CacheException(message: 'Failed to cache profile.');
      }
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to cache profile: $e');
    }
  }
}
