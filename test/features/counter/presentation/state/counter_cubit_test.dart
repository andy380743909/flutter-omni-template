import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/domain/usecases/get_counter.dart';
import 'package:app_template/features/counter/domain/usecases/increment_counter.dart';
import 'package:app_template/features/counter/presentation/state/counter_cubit.dart';
import 'package:app_template/features/counter/presentation/state/counter_state.dart';

class MockGetCounter extends Mock implements GetCounter {}

class MockIncrementCounter extends Mock implements IncrementCounter {}

void main() {
  late MockGetCounter getCounter;
  late MockIncrementCounter incrementCounter;

  setUp(() {
    getCounter = MockGetCounter();
    incrementCounter = MockIncrementCounter();
  });

  CounterCubit build() => CounterCubit(
        getCounter: getCounter,
        incrementCounter: incrementCounter,
      );

  group('CounterCubit', () {
    blocTest<CounterCubit, CounterState>(
      'emits [loading, loaded] when loadCounter succeeds',
      build: build,
      setUp: () => when(() => getCounter(const NoParams())).thenAnswer(
        (_) async => const Result<Counter, Failure>.success(Counter(value: 3)),
      ),
      act: (CounterCubit cubit) => cubit.loadCounter(),
      expect: () => const <CounterState>[
        CounterLoading(),
        CounterLoaded(Counter(value: 3)),
      ],
    );

    blocTest<CounterCubit, CounterState>(
      'emits [loading, error] when loadCounter fails',
      build: build,
      setUp: () => when(() => getCounter(const NoParams())).thenAnswer(
        (_) async =>
            const Result<Counter, Failure>.failure(CacheFailure(message: 'fail')),
      ),
      act: (CounterCubit cubit) => cubit.loadCounter(),
      expect: () => const <CounterState>[
        CounterLoading(),
        CounterError('fail'),
      ],
    );

    blocTest<CounterCubit, CounterState>(
      'emits [loading, loaded] when increment succeeds',
      build: build,
      setUp: () => when(() => incrementCounter(const NoParams())).thenAnswer(
        (_) async => const Result<Counter, Failure>.success(Counter(value: 1)),
      ),
      act: (CounterCubit cubit) => cubit.increment(),
      expect: () => const <CounterState>[
        CounterLoading(),
        CounterLoaded(Counter(value: 1)),
      ],
    );

    blocTest<CounterCubit, CounterState>(
      'emits [loading, error] when increment fails',
      build: build,
      setUp: () => when(() => incrementCounter(const NoParams())).thenAnswer(
        (_) async => const Result<Counter, Failure>.failure(
          UnknownFailure(message: 'err'),
        ),
      ),
      act: (CounterCubit cubit) => cubit.increment(),
      expect: () => const <CounterState>[
        CounterLoading(),
        CounterError('err'),
      ],
    );
  });
}
