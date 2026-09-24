import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/domain/repositories/counter_repository.dart';
import 'package:app_template/features/counter/domain/usecases/get_counter.dart';
import 'package:app_template/features/counter/domain/usecases/increment_counter.dart';

class MockCounterRepository extends Mock implements CounterRepository {}

void main() {
  late MockCounterRepository repository;
  late GetCounter getCounter;
  late IncrementCounter incrementCounter;

  setUp(() {
    repository = MockCounterRepository();
    getCounter = GetCounter(repository: repository);
    incrementCounter = IncrementCounter(repository: repository);
  });

  group('GetCounter', () {
    test('returns the counter on success', () async {
      when(() => repository.getCounter()).thenAnswer(
        (_) async => const Result<Counter, Failure>.success(Counter(value: 5)),
      );

      final Result<Counter, Failure> result = await getCounter(const NoParams());

      expect(result.isSuccess, isTrue);
      expect(result.successOrNull, const Counter(value: 5));
      verify(() => repository.getCounter()).called(1);
    });

    test('propagates a failure', () async {
      when(() => repository.getCounter()).thenAnswer(
        (_) async =>
            Result<Counter, Failure>.failure(CacheFailure(message: 'boom')),
      );

      final Result<Counter, Failure> result = await getCounter(const NoParams());

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<CacheFailure>());
    });
  });

  group('IncrementCounter', () {
    test('calls repository.increment and returns the new value', () async {
      when(() => repository.increment()).thenAnswer(
        (_) async => const Result<Counter, Failure>.success(Counter(value: 1)),
      );

      final Result<Counter, Failure> result =
          await incrementCounter(const NoParams());

      expect(result.successOrNull, const Counter(value: 1));
      verify(() => repository.increment()).called(1);
    });

    test('propagates a failure', () async {
      when(() => repository.increment()).thenAnswer(
        (_) async => Result<Counter, Failure>.failure(
          UnknownFailure(message: 'unknown'),
        ),
      );

      final Result<Counter, Failure> result =
          await incrementCounter(const NoParams());

      expect(result.isFailure, isTrue);
    });
  });
}
