import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/domain/repositories/counter_repository.dart';

/// Use case: read the current counter value.
class GetCounter implements UseCase<Counter, NoParams> {
  final CounterRepository repository;

  const GetCounter({required this.repository});

  @override
  Future<Result<Counter, Failure>> call(NoParams params) =>
      repository.getCounter();
}
