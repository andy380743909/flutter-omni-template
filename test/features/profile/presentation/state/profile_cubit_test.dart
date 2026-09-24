import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/core/errors/failures.dart';
import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/core/utils/result.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/domain/usecases/get_profile.dart';
import 'package:app_template/features/profile/presentation/state/profile_cubit.dart';
import 'package:app_template/features/profile/presentation/state/profile_state.dart';

class MockGetProfile extends Mock implements GetProfile {}

void main() {
  late MockGetProfile getProfile;

  setUp(() => getProfile = MockGetProfile());

  ProfileCubit build() => ProfileCubit(getProfile: getProfile);

  const UserProfile profile = UserProfile(
    id: '1',
    name: 'Ada',
    email: 'ada@example.com',
  );

  blocTest<ProfileCubit, ProfileState>(
    'emits [loading, loaded] when loadProfile succeeds',
    build: build,
    setUp: () => when(() => getProfile(const NoParams())).thenAnswer(
      (_) async => const Result<UserProfile, Failure>.success(profile),
    ),
    act: (ProfileCubit cubit) => cubit.loadProfile(),
    expect: () => const <ProfileState>[
      ProfileLoading(),
      ProfileLoaded(profile),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'emits [loading, error] when loadProfile fails',
    build: build,
    setUp: () => when(() => getProfile(const NoParams())).thenAnswer(
      (_) async =>
          const Result<UserProfile, Failure>.failure(ServerFailure(message: 'fail')),
    ),
    act: (ProfileCubit cubit) => cubit.loadProfile(),
    expect: () => const <ProfileState>[
      ProfileLoading(),
      ProfileError('fail'),
    ],
  );
}
