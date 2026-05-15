import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/settings_model.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories_impl/settings_repository_impl.dart';

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(_repository.getSettings());

  Future<void> updateSettings(SettingsModel settings) async {
    await _repository.saveSettings(settings);
    state = settings;
  }

  Future<void> completeSetup({
    required String shopName,
    required String currency,
    required String language,
    String? address,
    String? phone,
  }) async {
    final newSettings = SettingsModel(
      shopName: shopName,
      currency: currency,
      language: language,
      address: address,
      phone: phone,
      isDarkTheme: state.isDarkTheme,
      pinCode: state.pinCode,
      isSetupComplete: true,
    );
    await updateSettings(newSettings);
  }

  Future<void> setPinCode(String pin) async {
    final newSettings = SettingsModel(
      shopName: state.shopName,
      currency: state.currency,
      language: state.language,
      address: state.address,
      phone: state.phone,
      isDarkTheme: state.isDarkTheme,
      pinCode: pin,
      isSetupComplete: state.isSetupComplete,
    );
    await updateSettings(newSettings);
  }

  Future<void> updateLanguage(String lang) async {
    final newSettings = SettingsModel(
      shopName: state.shopName,
      currency: state.currency,
      language: lang,
      address: state.address,
      phone: state.phone,
      isDarkTheme: state.isDarkTheme,
      pinCode: state.pinCode,
      isSetupComplete: state.isSetupComplete,
    );
    await updateSettings(newSettings);
  }
}
