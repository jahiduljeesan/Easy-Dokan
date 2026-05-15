import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart'; // For localeProvider

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.language, size: 80, color: primaryColor),
              const SizedBox(height: 32),
              Text(
                'Select Language\nভাষা নির্বাচন করুন',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  ref.read(localeProvider.notifier).state = const Locale('en');
                  context.push('/setup_wizard');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('English', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  ref.read(localeProvider.notifier).state = const Locale('bn');
                  context.push('/setup_wizard');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  side: BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('বাংলা', style: TextStyle(fontSize: 18, color: primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
