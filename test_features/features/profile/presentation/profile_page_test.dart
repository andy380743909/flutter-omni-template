import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/presentation/pages/profile_page.dart';
import 'package:app_template/features/profile/presentation/state/profile_cubit.dart';
import 'package:app_template/features/profile/presentation/state/profile_state.dart';

class MockProfileCubit extends MockCubit<ProfileState> implements ProfileCubit {
  @override
  Future<void> loadProfile() => Future.value();
}

void main() {
  late MockProfileCubit cubit;

  setUp(() {
    cubit = MockProfileCubit();
    when(() => cubit.state).thenReturn(const ProfileInitial());
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProfileCubit>.value(
          value: cubit,
          child: const ProfilePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const UserProfile profile = UserProfile(
    id: '1',
    name: 'Ada',
    email: 'ada@example.com',
  );

  testWidgets('shows the start hint when initial', (WidgetTester tester) async {
    when(() => cubit.state).thenReturn(const ProfileInitial());
    await pumpPage(tester);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.text('Tap refresh to load your profile.'), findsOneWidget);
  });

  testWidgets('shows a loading indicator when loading', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const ProfileLoading());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the profile card when loaded', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const ProfileLoaded(profile));
    await pumpPage(tester);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
  });

  testWidgets('shows an error message with a retry button', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const ProfileError('boom'));
    await pumpPage(tester);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping refresh calls loadProfile()', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const ProfileLoaded(profile));
    when(() => cubit.loadProfile()).thenAnswer((_) async {});

    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('profile_refresh_button')));
    await tester.pumpAndSettle();

    verify(() => cubit.loadProfile()).called(1);
  });
}
