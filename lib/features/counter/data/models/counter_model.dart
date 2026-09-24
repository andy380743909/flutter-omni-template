import 'package:app_template/features/counter/domain/entities/counter.dart';

/// Data-layer model for [Counter].
///
/// Handles (de)serialization for persistence. It is a thin mapping wrapper over
/// the domain [Counter] entity.
class CounterModel {
  final int value;

  const CounterModel({required this.value});

  /// Builds a model from a JSON map (e.g. a stored record).
  factory CounterModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawValue = json['value'];
    if (rawValue is! int) {
      throw const FormatException('CounterModel requires an int "value".');
    }
    return CounterModel(value: rawValue);
  }

  /// Builds a model from a domain [Counter] entity.
  factory CounterModel.fromEntity(Counter entity) =>
      CounterModel(value: entity.value);

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{'value': value};

  /// Converts this model back to a domain [Counter] entity.
  Counter toEntity() => Counter(value: value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CounterModel && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CounterModel(value: $value)';
}
