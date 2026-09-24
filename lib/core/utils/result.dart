/// A functional result type forcing callers to handle both success and failure.
///
/// Use cases return [Result<Type, Failure>]; the [Failure] type parameter is
/// pinned to the domain [Failure] hierarchy so every failure is explainable.
///
/// Example:
/// ```dart
/// final result = await useCase(params);
/// result.fold(
///   onSuccess: (value) => print(value),
///   onFailure: (failure) => showError(failure.message),
/// );
/// ```
sealed class Result<S, F> {
  const Result();

  /// Creates a successful result holding [value].
  const factory Result.success(S value) = Success<S, F>;

  /// Creates a failed result holding [failure].
  const factory Result.failure(F failure) = FailureResult<S, F>;

  /// Whether this is a [Success].
  bool get isSuccess => this is Success<S, F>;

  /// Whether this is a [FailureResult].
  bool get isFailure => this is FailureResult<S, F>;

  /// The success value, or `null` when this is a failure.
  S? get successOrNull => isSuccess ? (this as Success<S, F>).value : null;

  /// The failure value, or `null` when this is a success.
  F? get failureOrNull =>
      isFailure ? (this as FailureResult<S, F>).failure : null;

  /// Pattern-matches on success/failure and returns a unified value.
  R fold<R>({
    required R Function(S value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    if (this is Success<S, F>) {
      return onSuccess((this as Success<S, F>).value);
    }
    return onFailure((this as FailureResult<S, F>).failure);
  }
}

/// Successful [Result] holding a value of type [S].
final class Success<S, F> extends Result<S, F> {
  final S value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<S, F> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Failed [Result] holding a failure of type [F].
final class FailureResult<S, F> extends Result<S, F> {
  final F failure;

  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<S, F> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
