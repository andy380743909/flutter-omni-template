import 'package:app_template/features/counter/domain/entities/counter.dart';

/// Immutable state for the counter feature.
///
/// Four explicit states mirror the loading lifecycle: initial, loading, loaded
/// and error. States are handwritten (no code generation) so the template stays
/// dependency-light.
sealed class CounterState {
  const CounterState();
}

/// Shown before the first load attempt.
final class CounterInitial extends CounterState {
  const CounterInitial();

  @override
  bool operator ==(Object other) => other is CounterInitial;

  @override
  int get hashCode => 0;
}

/// Shown while a load/increment is in flight.
final class CounterLoading extends CounterState {
  const CounterLoading();

  @override
  bool operator ==(Object other) => other is CounterLoading;

  @override
  int get hashCode => 1;
}

/// Shown once the counter value is available.
final class CounterLoaded extends CounterState {
  final Counter counter;

  const CounterLoaded(this.counter);

  @override
  bool operator ==(Object other) =>
      other is CounterLoaded && other.counter == counter;

  @override
  int get hashCode => counter.hashCode;
}

/// Shown when an operation fails.
final class CounterError extends CounterState {
  final String message;

  const CounterError(this.message);

  @override
  bool operator ==(Object other) =>
      other is CounterError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
