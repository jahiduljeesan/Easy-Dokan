import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../localization/app_localizations.dart';
import '../../main.dart';
import 'settings_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/settings_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr(context)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Theme'),
                  subtitle: const Text('Toggle light and dark mode appearance'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.dark_mode_rounded, color: Colors.purple.shade600),
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state = val
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.language_rounded, color: Colors.blue.shade600),
                  ),
                  title: Text('language'.tr(context)),
                  subtitle: const Text('Choose application display language'),
                  trailing: DropdownButton<String>(
                    value: ref.read(localeProvider).languageCode,
                    underline: const SizedBox(),
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
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Store & Security'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store_rounded, color: Colors.orange.shade600),
                  ),
                  title: const Text('Shop Profile'),
                  subtitle: Text('${settings.shopName} (${settings.currency})'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showShopDetailsDialog(context, ref, settings);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded, color: Colors.green.shade600),
                  ),
                  title: const Text('Security PIN Lock'),
                  subtitle: Text(
                    (settings.pinCode != null && settings.pinCode!.isNotEmpty)
                        ? 'PIN protection active'
                        : 'Configure a security lock PIN',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _showPinDialog(context, ref);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Management'),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.backup_rounded, color: Colors.teal.shade600),
                  ),
                  title: const Text('Export Data Backup'),
                  subtitle: const Text('Share database backup file securely'),
                  trailing: const Icon(Icons.share_rounded),
                  onTap: () {
                    _exportDatabase(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showShopDetailsDialog(BuildContext context, WidgetRef ref, SettingsModel settings) {
    final nameController = TextEditingController(text: settings.shopName);
    final phoneController = TextEditingController(text: settings.phone ?? '');
    final addressController = TextEditingController(text: settings.address ?? '');
    final currencyController = TextEditingController(text: settings.currency);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.store_rounded, color: Colors.blue),
            SizedBox(width: 10),
            Text('Shop Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: const Icon(Icons.shop_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currencyController,
                decoration: InputDecoration(
                  labelText: 'Currency Symbol',
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && currencyController.text.isNotEmpty) {
                final updated = SettingsModel(
                  shopName: nameController.text,
                  currency: currencyController.text,
                  language: settings.language,
                  address: addressController.text,
                  phone: phoneController.text,
                  isDarkTheme: settings.isDarkTheme,
                  pinCode: settings.pinCode,
                  isSetupComplete: settings.isSetupComplete,
                );
                await ref.read(settingsNotifierProvider.notifier).updateSettings(updated);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.green),
            SizedBox(width: 10),
            Text('Set Security PIN', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: '4-digit PIN',
                prefixIcon: const Icon(Icons.pin_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => newPin = val,
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportDatabase(BuildContext context) async {
    try {
      final productBox = Hive.box<ProductModel>('products');
      final saleBox = Hive.box<SaleModel>('sales');
      
      final productsJson = productBox.values.map((p) => {
        'uid': p.uid,
        'barcodeId': p.barcodeId,
        'name': p.name,
        'banglaName': p.banglaName,
        'category': p.category,
        'brand': p.brand,
        'buyingPrice': p.buyingPrice,
        'sellingPrice': p.sellingPrice,
        'wholesalePrice': p.wholesalePrice,
        'quantity': p.quantity,
        'unit': p.unit,
        'isMeasurable': p.isMeasurable,
      }).toList();

      final salesJson = saleBox.values.map((s) => {
        'id': s.id,
        'total': s.total,
        'paidAmount': s.paidAmount,
        'dueAmount': s.dueAmount,
        'profit': s.profit,
        'customerId': s.customerId,
        'date': s.date.toIso8601String(),
      }).toList();

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'products': productsJson,
        'sales': salesJson,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/easy_dokan_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await backupFile.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'Easy Dokan DB Backup',
        text: 'Backup created on ${DateTime.now().toString().substring(0, 19)}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Backup exported successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
