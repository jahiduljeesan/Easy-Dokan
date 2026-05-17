import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
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
          // Top Shop Header Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    settings.shopName.isNotEmpty ? settings.shopName[0].toUpperCase() : 'E',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.shopName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      if (settings.phone != null && settings.phone!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              settings.phone!,
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (settings.address != null && settings.address!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                settings.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                    final updated = SettingsModel(
                      shopName: settings.shopName,
                      currency: settings.currency,
                      language: settings.language,
                      address: settings.address,
                      phone: settings.phone,
                      isDarkTheme: val,
                      pinCode: settings.pinCode,
                      isSetupComplete: settings.isSetupComplete,
                    );
                    ref.read(settingsNotifierProvider.notifier).updateSettings(updated);
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
                    if (settings.pinCode != null && settings.pinCode!.isNotEmpty) {
                      _showPinOptionsDialog(context, ref, settings);
                    } else {
                      _showSetPinDialog(context, ref);
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.vpn_key_rounded, color: Colors.indigo.shade600),
                  ),
                  title: const Text('Credential Storage Vault'),
                  subtitle: const Text('Store API keys, credentials & secrets'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    context.push('/settings/credentials');
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
    final ownerNameController = TextEditingController(text: settings.ownerName ?? '');
    final emailController = TextEditingController(text: settings.businessEmail ?? '');
    final tradeLicenseController = TextEditingController(text: settings.tradeLicense ?? '');

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
              const SizedBox(height: 12),
              TextField(
                controller: ownerNameController,
                decoration: InputDecoration(
                  labelText: 'Owner / Credential Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Business Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tradeLicenseController,
                decoration: InputDecoration(
                  labelText: 'Trade License / NID No',
                  prefixIcon: const Icon(Icons.badge_outlined),
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
                  ownerName: ownerNameController.text,
                  businessEmail: emailController.text,
                  tradeLicense: tradeLicenseController.text,
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

  void _showSetPinDialog(BuildContext context, WidgetRef ref) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text('Set PIN Lock', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Secure your POS with a 4-digit PIN.'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Enter 4-digit PIN',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Confirm 4-digit PIN',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = pinController.text;
                final confirm = confirmController.text;
                if (pin.length != 4) {
                  setState(() {
                    errorMessage = 'PIN must be exactly 4 digits';
                  });
                } else if (pin != confirm) {
                  setState(() {
                    errorMessage = 'PINs do not match';
                  });
                } else {
                  ref.read(settingsNotifierProvider.notifier).setPinCode(pin);
                  Navigator.pop(context);
                  _showSuccessSnackbar(context, 'Security PIN configured successfully!');
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinOptionsDialog(BuildContext context, WidgetRef ref, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Colors.green),
            SizedBox(width: 10),
            Text('PIN Protection', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your POS app is currently protected by a PIN lock.'),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_reset_rounded, color: Colors.blue.shade600),
              ),
              title: const Text('Change Security PIN'),
              subtitle: const Text('Set a new 4-digit screen lock PIN'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                _showChangePinDialog(context, ref, settings);
              },
            ),
            const Divider(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_open_rounded, color: Colors.red.shade600),
              ),
              title: const Text('Remove PIN Protection'),
              subtitle: const Text('Disable lock screen security'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                _showRemovePinDialog(context, ref, settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, WidgetRef ref, SettingsModel settings) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Text('Change PIN', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Current 4-digit PIN',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'New 4-digit PIN',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Confirm New 4-digit PIN',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    counterText: '',
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final current = currentController.text;
                final newPin = newController.text;
                final confirm = confirmController.text;

                if (current != settings.pinCode) {
                  setState(() {
                    errorMessage = 'Current PIN is incorrect';
                  });
                } else if (newPin.length != 4) {
                  setState(() {
                    errorMessage = 'New PIN must be exactly 4 digits';
                  });
                } else if (newPin != confirm) {
                  setState(() {
                    errorMessage = 'New PINs do not match';
                  });
                } else {
                  ref.read(settingsNotifierProvider.notifier).setPinCode(newPin);
                  Navigator.pop(context);
                  _showSuccessSnackbar(context, 'Security PIN updated successfully!');
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemovePinDialog(BuildContext context, WidgetRef ref, SettingsModel settings) {
    final pinController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_open_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Remove PIN Protection', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please enter your current 4-digit PIN to disable lock protection.'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Current 4-digit PIN',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '',
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = pinController.text;
                if (pin != settings.pinCode) {
                  setState(() {
                    errorMessage = 'Incorrect security PIN';
                  });
                } else {
                  ref.read(settingsNotifierProvider.notifier).setPinCode('');
                  Navigator.pop(context);
                  _showSuccessSnackbar(context, 'Security PIN protection disabled.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        _showSuccessSnackbar(context, 'Backup exported successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
