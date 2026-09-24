import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_template/features/profile/domain/usecases/get_profile.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;
  late GetProfile getProfile;

  setUp(() {
    repository = MockProfileRepository();
    getProfile = GetProfile(repository: repository);
  });

  const UserProfile profile = UserProfile(
    id: '1',
    name: 'Ada',
    email: 'ada@example.com',
  );

  test('returns the profile on success', () async {
    when(() => repository.getProfile()).thenAnswer(
      (_) async => const Result<UserProfile, Failure>.success(profile),
    );

    final Result<UserProfile, Failure> result =
        await getProfile(const NoParams());

    expect(result.isSuccess, isTrue);
    expect(result.successOrNull, profile);
    verify(() => repository.getProfile()).called(1);
  });

  test('propagates a failure', () async {
    when(() => repository.getProfile()).thenAnswer(
      (_) async =>
          Result<UserProfile, Failure>.failure(ServerFailure(message: 'boom')),
    );

    final Result<UserProfile, Failure> result =
        await getProfile(const NoParams());

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
