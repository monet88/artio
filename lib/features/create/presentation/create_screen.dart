import 'package:flutter/material.dart';
import 'package:artio/core/design_system/app_spacing.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'This feature is under development',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
