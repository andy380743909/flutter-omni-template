/// Small, reusable Dart extensions shared across the codebase.

/// Extensions on [String].
extension StringExtension on String {
  /// Capitalizes the first character, leaving the rest unchanged.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns `true` when the string is null, empty, or whitespace-only.
  bool get isBlank => trim().isEmpty;
}

/// Extensions on [num].
extension NumExtension on num {
  /// Clamps the value into the inclusive [min]..[max] range.
  num clampTo(num min, num max) => this < min ? min : (this > max ? max : this);
}

/// Extensions on [DateTime].
extension DateTimeExtension on DateTime {
  /// Returns an ISO-8601-ish `yyyy-MM-dd` representation.
  String get toDateString => '$year-${_pad(month)}-${_pad(day)}';

  String _pad(int value) => value.toString().padLeft(2, '0');
}
