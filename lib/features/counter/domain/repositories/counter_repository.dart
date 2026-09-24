import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';

/// Abstraction the domain layer depends on. The data layer provides the
/// concrete implementation; the UI never sees the implementation details.
abstract class CounterRepository {
  /// Returns the currently persisted counter value.
  Future<Result<Counter, Failure>> getCounter();

  /// Increments the counter by one and returns the new value.
  Future<Result<Counter, Failure>> increment();
}
