import 'package:flutter/material.dart';

import 'package:app_template/features/profile/domain/entities/profile.dart';

/// Reusable widget that displays a [UserProfile] as a card.
class ProfileCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String initial = profile.name.trim().isEmpty
        ? '?'
        : profile.name.trim()[0].toUpperCase();
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 32,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null ? Text(initial) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(profile.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(profile.email, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
