import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../localization/app_localizations.dart';
import '../settings/settings_provider.dart';
import '../../main.dart';

class ShopWizardScreen extends ConsumerStatefulWidget {
  const ShopWizardScreen({super.key});

  @override
  ConsumerState<ShopWizardScreen> createState() => _ShopWizardScreenState();
}

class _ShopWizardScreenState extends ConsumerState<ShopWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCurrency = '৳';
  String? _pinCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('setup_shop'.tr(context)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'shop_name'.tr(context),
                  prefixIcon: const Icon(Icons.store),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'address'.tr(context),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'phone'.tr(context),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'PIN Lock (Optional)',
                  prefixIcon: const Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onChanged: (v) {
                  // we could store pin in a variable
                  _pinCode = v.isEmpty ? null : v;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'currency'.tr(context),
                  prefixIcon: const Icon(Icons.monetization_on),
                ),
                items: ['৳', '\$', '€', '₹'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    if (v != null) _selectedCurrency = v;
                  });
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref.read(settingsNotifierProvider.notifier).completeSetup(
                      shopName: _nameController.text,
                      currency: _selectedCurrency,
                      language: ref.read(localeProvider).languageCode,
                      address: _addressController.text,
                      phone: _phoneController.text,
                    );
                    if (_pinCode != null) {
                      await ref.read(settingsNotifierProvider.notifier).setPinCode(_pinCode!);
                    }
                    if (context.mounted) {
                      context.go('/dashboard');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('continue_btn'.tr(context), style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
