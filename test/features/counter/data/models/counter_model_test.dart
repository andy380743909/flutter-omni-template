import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/counter/data/models/counter_model.dart';
import 'package:app_template/features/counter/domain/entities/counter.dart';

void main() {
  group('CounterModel', () {
    test('fromJson reads the int value', () {
      final CounterModel model =
          CounterModel.fromJson(<String, dynamic>{'value': 7});
      expect(model.value, 7);
    });

    test('fromJson throws on a non-int value', () {
      expect(
        () => CounterModel.fromJson(<String, dynamic>{'value': 'seven'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips', () {
      const CounterModel model = CounterModel(value: 7);
      expect(model.toJson(), <String, dynamic>{'value': 7});
    });

    test('entity mapping is symmetric', () {
      const Counter entity = Counter(value: 10);
      final CounterModel model = CounterModel.fromEntity(entity);
      expect(model.toEntity(), const Counter(value: 10));
    });

    test('equality compares by value', () {
      expect(
        const CounterModel(value: 1),
        const CounterModel(value: 1),
      );
      expect(
        const CounterModel(value: 1) == const CounterModel(value: 2),
        isFalse,
      );
    });
  });
}
