import 'package:flutter/material.dart';

import 'package:app_template/features/counter/domain/entities/counter.dart';

/// Reusable widget that displays a [Counter]'s value.
class CounterDisplay extends StatelessWidget {
  final Counter counter;

  const CounterDisplay({
    super.key,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'You have pushed the button this many times:',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${counter.value}',
          style: theme.textTheme.headlineMedium,
        ),
      ],
    );
  }
}
