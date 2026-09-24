import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/domain/usecases/get_counter.dart';
import 'package:app_template/features/counter/domain/usecases/increment_counter.dart';
import 'package:app_template/features/counter/presentation/state/counter_state.dart';

/// Stateful coordinator for the counter feature.
///
/// The Cubit only orchestrates state transitions; all business rules live in
/// the injected use cases. It emits [CounterLoading] before each operation and
/// then either [CounterLoaded] or [CounterError].
class CounterCubit extends Cubit<CounterState> {
  final GetCounter getCounter;
  final IncrementCounter incrementCounter;

  CounterCubit({
    required this.getCounter,
    required this.incrementCounter,
  }) : super(const CounterInitial());

  /// Loads the persisted counter value.
  Future<void> loadCounter() async {
    emit(const CounterLoading());
    final result = await getCounter(const NoParams());
    result.fold(
      onSuccess: (Counter counter) => emit(CounterLoaded(counter)),
      onFailure: (failure) => emit(CounterError(failure.message)),
    );
  }

  /// Increments the counter and emits the new value.
  Future<void> increment() async {
    emit(const CounterLoading());
    final result = await incrementCounter(const NoParams());
    result.fold(
      onSuccess: (Counter counter) => emit(CounterLoaded(counter)),
      onFailure: (failure) => emit(CounterError(failure.message)),
    );
  }
}
