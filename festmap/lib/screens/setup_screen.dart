import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/festmap_theme.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  static const steps = [
    'Create a Firebase project and enable Cloud Firestore.',
    'From festmap/, run: dart pub global activate flutterfire_cli',
    'Run: flutterfire configure (generates lib/firebase_options.dart).',
    'Add google-services.json (Android) and GoogleService-Info.plist (iOS).',
    'Enable Maps SDK for Android/iOS and add API keys to platform configs.',
    'Deploy rules: firebase deploy --only firestore:rules (from firebase/).',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FestMapColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FESTMAP setup',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Firebase is not configured yet. Replace the placeholder '
                'firebase_options.dart or run flutterfire configure.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ...steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}.',
                        style: const TextStyle(color: FestMapColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'flutterfire configure'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied flutterfire configure')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy flutterfire command'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
