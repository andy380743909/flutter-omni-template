import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/domain/repositories/counter_repository.dart';

/// Use case: increment the counter by one and return the new value.
class IncrementCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;

  const IncrementCounter({required this.repository});

  @override
  Future<Result<Counter, Failure>> call(NoParams params) =>
      repository.increment();
}
