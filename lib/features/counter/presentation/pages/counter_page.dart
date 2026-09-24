import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_template/features/counter/presentation/state/counter_cubit.dart';
import 'package:app_template/features/counter/presentation/state/counter_state.dart';
import 'package:app_template/features/counter/presentation/widgets/counter_display.dart';
import 'package:app_template/shared/widgets/app_error.dart';
import 'package:app_template/shared/widgets/app_loading.dart';

/// Example page demonstrating the full Clean Architecture flow:
/// UI -> Cubit -> UseCase -> Repository -> DataSource -> Storage.
///
/// The [CounterCubit] is provided by an ancestor [BlocProvider] (see `app.dart`).
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  /// Route name used by the app router.
  static const String routeName = '/counter';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.article),
            tooltip: 'Articles',
            onPressed: () => Navigator.of(context).pushNamed('/articles'),
          ),
        ],
      ),
      body: BlocBuilder<CounterCubit, CounterState>(
        builder: (BuildContext context, CounterState state) {
          if (state is CounterLoading) {
            return const AppLoading();
          } else if (state is CounterError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<CounterCubit>().loadCounter(),
            );
          } else if (state is CounterLoaded) {
            return CounterDisplay(counter: state.counter);
          }
          return const Center(
            child: Text('Press + to start counting.'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('counter_increment_button'),
        tooltip: 'Increment',
        onPressed: () => context.read<CounterCubit>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
