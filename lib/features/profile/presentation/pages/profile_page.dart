import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_template/features/profile/presentation/state/profile_cubit.dart';
import 'package:app_template/features/profile/presentation/state/profile_state.dart';
import 'package:app_template/features/profile/presentation/widgets/profile_card.dart';
import 'package:app_template/shared/widgets/app_error.dart';
import 'package:app_template/shared/widgets/app_loading.dart';

/// Example page demonstrating a network-backed feature through the full
/// Clean Architecture flow:
/// UI -> Cubit -> UseCase -> Repository -> (Remote + Local) DataSources.
///
/// The [ProfileCubit] is provided by an ancestor [BlocProvider] (see `app.dart`).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Route name used by the app router.
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            key: const Key('profile_refresh_button'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<ProfileCubit>().loadProfile(),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          if (state is ProfileLoading) {
            return const AppLoading();
          } else if (state is ProfileError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<ProfileCubit>().loadProfile(),
            );
          } else if (state is ProfileLoaded) {
            return ProfileCard(profile: state.profile);
          }
          return const Center(
            child: Text('Tap refresh to load your profile.'),
          );
        },
      ),
    );
  }
}
