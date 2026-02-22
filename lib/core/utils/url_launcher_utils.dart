import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a URL in the device browser, silently logging any failures.
Future<void> launchUrlSafely(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open link'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Sends an email using the device's mail app.
Future<void> launchEmailSafely(
  BuildContext context, {
  required String to,
  String subject = '',
  String body = '',
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: to,
    query: [
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&'),
  );

  if (!await launchUrl(uri)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open mail app'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
