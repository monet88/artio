import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet prompting the user to sign in or register
/// before proceeding with a create action.
void showAuthGateSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Theme.of(sheetContext).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sign in to create',
            style: Theme.of(sheetContext).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create an account or sign in to start generating AI art',
            style: Theme.of(sheetContext).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                const LoginRoute().go(context);
              },
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                const RegisterRoute().go(context);
              },
              child: const Text('Create Account'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}
