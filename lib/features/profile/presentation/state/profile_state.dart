import 'package:app_template/features/profile/domain/entities/profile.dart';

/// Immutable state for the profile feature.
///
/// Four explicit states mirror the loading lifecycle: initial, loading, loaded
/// and error. States are handwritten (no code generation) so the template stays
/// dependency-light.
sealed class ProfileState {
  const ProfileState();
}

/// Shown before the first load attempt.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  bool operator ==(Object other) => other is ProfileInitial;

  @override
  int get hashCode => 0;
}

/// Shown while a load is in flight.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  bool operator ==(Object other) => other is ProfileLoading;

  @override
  int get hashCode => 1;
}

/// Shown once the profile is available.
final class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  bool operator ==(Object other) =>
      other is ProfileLoaded && other.profile == profile;

  @override
  int get hashCode => profile.hashCode;
}

/// Shown when an operation fails.
final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  bool operator ==(Object other) =>
      other is ProfileError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
