import 'package:app_template/core/errors/exceptions.dart';
import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/counter/data/datasources/counter_local_datasource.dart';
import 'package:app_template/features/counter/data/models/counter_model.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/domain/repositories/counter_repository.dart';

/// Concrete [CounterRepository] that delegates to [CounterLocalDataSource].
///
/// Catches low-level [AppException]s and converts them into domain [Failure]s,
/// never leaking implementation details above the data layer.
class CounterRepositoryImpl implements CounterRepository {
  final CounterLocalDataSource localDataSource;

  const CounterRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<Counter, Failure>> getCounter() async {
    try {
      final CounterModel model = await localDataSource.getLastCounter();
      return Result.success(model.toEntity());
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Counter, Failure>> increment() async {
    try {
      final CounterModel model = await localDataSource.increment();
      return Result.success(model.toEntity());
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
