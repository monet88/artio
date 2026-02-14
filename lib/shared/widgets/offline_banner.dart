import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/connectivity_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline = connectivityAsync.whenOrNull(
      data: (isConnected) => !isConnected,
    ) ?? false;

    if (!isOffline) return const SizedBox.shrink();

    return MaterialBanner(
      content: const Text('No internet connection'),
      leading: const Icon(Icons.wifi_off),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      contentTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      actions: [
        TextButton(
          onPressed: () => ref.invalidate(connectivityProvider),
          child: const Text('Dismiss'),
        ),
      ],
    );
  }
}
