import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:app_template/features/counter/domain/entities/counter.dart';
import 'package:app_template/features/counter/presentation/pages/counter_page.dart';
import 'package:app_template/features/counter/presentation/state/counter_cubit.dart';
import 'package:app_template/features/counter/presentation/state/counter_state.dart';

class MockCounterCubit extends MockCubit<CounterState>
    implements CounterCubit {}

void main() {
  late MockCounterCubit cubit;

  setUp(() {
    cubit = MockCounterCubit();
    when(() => cubit.state).thenReturn(const CounterInitial());
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CounterCubit>.value(
          value: cubit,
          child: const CounterPage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the start hint when state is initial', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const CounterInitial());
    await pumpPage(tester);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Press + to start counting.'), findsOneWidget);
  });

  testWidgets('shows a loading indicator when state is loading', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const CounterLoading());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the counter value when loaded', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const CounterLoaded(Counter(value: 5)));
    await pumpPage(tester);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('shows an error message with a retry button', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const CounterError('boom'));
    await pumpPage(tester);
    expect(find.text('boom'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping the FAB calls increment()', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const CounterLoaded(Counter(value: 1)));
    when(() => cubit.increment()).thenAnswer((_) async {});

    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('counter_increment_button')));
    await tester.pumpAndSettle();

    verify(() => cubit.increment()).called(1);
  });

  testWidgets('tapping retry calls loadCounter()', (
    WidgetTester tester,
  ) async {
    when(() => cubit.state).thenReturn(const CounterError('boom'));
    when(() => cubit.loadCounter()).thenAnswer((_) async {});

    await pumpPage(tester);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    verify(() => cubit.loadCounter()).called(1);
  });
}
