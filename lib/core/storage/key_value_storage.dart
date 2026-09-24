/// Platform-agnostic key/value storage abstraction.
///
/// The app depends only on this interface; the concrete implementation
/// ([SharedPreferencesStorage]) is injected via DI. Keeping the interface in
/// `core` means the data layer stays testable and storage backends are swappable
/// (e.g. `flutter_secure_storage` for encrypted values).
abstract class KeyValueStorage {
  /// Reads a [String] value, or `null` when the [key] is absent.
  Future<String?> readString({required String key});

  /// Writes a [String] value, returning whether the write succeeded.
  Future<bool> writeString({required String key, required String value});

  /// Reads an [int] value, or `null` when the [key] is absent.
  Future<int?> readInt({required String key});

  /// Writes an [int] value, returning whether the write succeeded.
  Future<bool> writeInt({required String key, required int value});

  /// Reads a [bool] value, or `null` when the [key] is absent.
  Future<bool?> readBool({required String key});

  /// Writes a [bool] value, returning whether the write succeeded.
  Future<bool> writeBool({required String key, required bool value});

  /// Removes a single [key], returning whether the removal succeeded.
  Future<bool> remove({required String key});

  /// Clears all entries, returning whether the clear succeeded.
  Future<bool> clear();
}
