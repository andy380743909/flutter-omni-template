import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/profile/data/models/profile_model.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';

void main() {
  group('ProfileModel', () {
    const UserProfile entity = UserProfile(
      id: '1',
      name: 'Ada',
      email: 'ada@example.com',
      avatarUrl: 'https://example.com/y.png',
    );

    test('fromJson reads fields', () {
      final ProfileModel model = ProfileModel.fromJson(<String, dynamic>{
        'id': '1',
        'name': 'Ada',
        'email': 'ada@example.com',
        'avatarUrl': 'https://example.com/y.png',
      });
      expect(model.id, '1');
      expect(model.avatarUrl, 'https://example.com/y.png');
    });

    test('fromJson treats missing avatarUrl as null', () {
      final ProfileModel model = ProfileModel.fromJson(<String, dynamic>{
        'id': '1',
        'name': 'Ada',
        'email': 'ada@example.com',
      });
      expect(model.avatarUrl, isNull);
    });

    test('fromJson throws on missing required fields', () {
      expect(
        () => ProfileModel.fromJson(<String, dynamic>{'id': '1'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toJson round-trips', () {
      final ProfileModel model = ProfileModel.fromEntity(entity);
      expect(model.toJson(), <String, dynamic>{
        'id': '1',
        'name': 'Ada',
        'email': 'ada@example.com',
        'avatarUrl': 'https://example.com/y.png',
      });
    });

    test('entity mapping is symmetric', () {
      final ProfileModel model = ProfileModel.fromEntity(entity);
      expect(model.toEntity(), entity);
    });

    test('equality compares by value', () {
      expect(
        const ProfileModel(id: '1', name: 'A', email: 'a@b.c'),
        const ProfileModel(id: '1', name: 'A', email: 'a@b.c'),
      );
      expect(
        const ProfileModel(id: '1', name: 'A', email: 'a@b.c') ==
            const ProfileModel(id: '2', name: 'A', email: 'a@b.c'),
        isFalse,
      );
    });
  });
}
