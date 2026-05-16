import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localization/app_localizations.dart';
import '../../main.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr(context))),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: themeMode == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).state = val
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('language'.tr(context)),
            trailing: DropdownButton<String>(
              value: ref.read(localeProvider).languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .updateLanguage(val);
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Set PIN Lock'),
            subtitle: Text(
              (settings.pinCode != null && settings.pinCode!.isNotEmpty)
                  ? 'PIN is set'
                  : 'No PIN',
            ),
            onTap: () {
              _showPinDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Shop Details'),
            subtitle: Text('${settings.shopName} - ${settings.currency}'),
            onTap: () {
              // Edit shop details
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Database'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup feature to be implemented'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPinDialog(BuildContext context, WidgetRef ref) {
    String newPin = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(labelText: '4-digit PIN'),
          onChanged: (val) => newPin = val,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).setPinCode('');
              Navigator.pop(context);
            },
            child: const Text(
              'Remove PIN',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPin.length == 4) {
                ref.read(settingsNotifierProvider.notifier).setPinCode(newPin);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
