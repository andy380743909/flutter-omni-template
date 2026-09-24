import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/core/utils/result.dart';

void main() {
  group('Result', () {
    test('success holds its value', () {
      const Result<int, String> result = Result<int, String>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.successOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('failure holds its failure', () {
      const Result<int, String> result = Result<int, String>.failure('oops');
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.failureOrNull, 'oops');
      expect(result.successOrNull, isNull);
    });

    test('fold dispatches to the correct branch', () {
      const Result<int, String> ok = Result<int, String>.success(1);
      const Result<int, String> err = Result<int, String>.failure('x');

      expect(
        ok.fold(onSuccess: (int v) => v * 2, onFailure: (String f) => -1),
        2,
      );
      expect(
        err.fold(onSuccess: (int v) => v * 2, onFailure: (String f) => f.length),
        1,
      );
    });

    test('equality compares by value', () {
      expect(
        const Result<int, String>.success(1),
        const Result<int, String>.success(1),
      );
      expect(
        const Result<int, String>.failure('a'),
        const Result<int, String>.failure('a'),
      );
      expect(
        const Result<int, String>.success(1) ==
            const Result<int, String>.success(2),
        isFalse,
      );
      expect(
        const Result<int, String>.failure('a') ==
            const Result<int, String>.failure('b'),
        isFalse,
      );
    });
  });
}
