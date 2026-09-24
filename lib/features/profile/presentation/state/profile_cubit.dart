import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_template/core/usecases/usecase.dart';
import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/domain/usecases/get_profile.dart';
import 'package:app_template/features/profile/presentation/state/profile_state.dart';

/// Stateful coordinator for the profile feature.
///
/// The Cubit only orchestrates state transitions; all business rules live in
/// the injected use case. It emits [ProfileLoading] before the operation and
/// then either [ProfileLoaded] or [ProfileError].
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfile getProfile;

  ProfileCubit({required this.getProfile}) : super(const ProfileInitial());

  /// Loads the user's profile.
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await getProfile(const NoParams());
    result.fold(
      onSuccess: (UserProfile profile) => emit(ProfileLoaded(profile)),
      onFailure: (failure) => emit(ProfileError(failure.message)),
    );
  }
}
