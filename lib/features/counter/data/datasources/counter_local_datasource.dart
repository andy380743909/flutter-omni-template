import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/storage/key_value_storage.dart';
import 'package:app_template/features/counter/data/models/counter_model.dart';

/// Local persistence boundary for the counter.
///
/// Reads/writes the counter value through the [KeyValueStorage] abstraction.
/// Any low-level failure is surfaced as a [CacheException] for the repository
/// to translate into a domain [Failure].
abstract class CounterLocalDataSource {
  /// Returns the last persisted counter, defaulting to 0 when absent.
  Future<CounterModel> getLastCounter();

  /// Reads the current value, adds one, persists it, and returns the new value.
  Future<CounterModel> increment();
}

/// [CounterLocalDataSource] backed by [KeyValueStorage].
class CounterLocalDataSourceImpl implements CounterLocalDataSource {
  static const String _storageKey = 'counter';

  final KeyValueStorage storage;

  const CounterLocalDataSourceImpl({required this.storage});

  @override
  Future<CounterModel> getLastCounter() async {
    try {
      final int? stored = await storage.readInt(key: _storageKey);
      return CounterModel(value: stored ?? 0);
    } catch (e) {
      throw CacheException(message: 'Failed to read counter: $e');
    }
  }

  @override
  Future<CounterModel> increment() async {
    try {
      final CounterModel current = await getLastCounter();
      final CounterModel next = CounterModel(value: current.value + 1);
      final bool ok =
          await storage.writeInt(key: _storageKey, value: next.value);
      if (!ok) {
        throw const CacheException(message: 'Failed to persist counter.');
      }
      return next;
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to increment counter: $e');
    }
  }
}
