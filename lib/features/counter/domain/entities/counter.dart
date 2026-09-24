/// Domain entity representing a simple integer counter.
///
/// Entities are plain, framework-agnostic value objects. Business rules that
/// operate on the counter (e.g. incrementing) live here as pure functions.
class Counter {
  final int value;

  const Counter({required this.value});

  /// Returns a new [Counter] with its value incremented by one.
  Counter increment() => Counter(value: value + 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Counter && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Counter(value: $value)';
}
