import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/utils/result.dart';

/// Base class for all use cases (interactors).
///
/// A use case encapsulates a single business operation. It always returns a
/// [Result] so the caller is forced to handle success and failure explicitly.
abstract class UseCase<Type, Params> {
  const UseCase();

  /// Executes the use case with the given [params].
  Future<Result<Type, Failure>> call(Params params);
}

/// Marker object used by use cases that require no parameters.
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;
}
