import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:app_template/di/injection_container.dart' as di;
import 'package:app_template/features/counter/presentation/pages/counter_page.dart';
import 'package:app_template/features/counter/presentation/state/counter_cubit.dart';
import 'package:app_template/features/profile/presentation/pages/profile_page.dart';
import 'package:app_template/features/profile/presentation/state/profile_cubit.dart';
import 'package:app_template/shared/theme/app_theme.dart';

/// Root widget for the application.
///
/// Configures Material theming, localization delegates, and injects the
/// [CounterCubit] (provided by the DI container) into the [CounterPage].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Template',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<CounterCubit>(
        create: (_) => di.sl<CounterCubit>()..loadCounter(),
        child: const CounterPage(),
      ),
      routes: <String, WidgetBuilder>{
        ProfilePage.routeName: (_) => BlocProvider<ProfileCubit>(
              create: (_) => di.sl<ProfileCubit>()..loadProfile(),
              child: const ProfilePage(),
            ),
      },
    );
  }
}
