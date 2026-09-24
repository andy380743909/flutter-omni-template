import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_template/features/profile/domain/entities/profile.dart';
import 'package:app_template/features/profile/presentation/widgets/profile_card.dart';

void main() {
  group('ProfileCard', () {
    const UserProfile profile = UserProfile(
      id: '1',
      name: 'Ada Lovelace',
      email: 'ada@example.com',
    );

    testWidgets('renders name and email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileCard(profile: profile)),
        ),
      );

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.byType(ProfileCard), findsOneWidget);
    });

    testWidgets('renders an initial letter when no avatar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileCard(profile: profile)),
        ),
      );

      // The CircleAvatar falls back to the first letter of the name.
      expect(find.text('A'), findsWidgets);
    });
  });
}
