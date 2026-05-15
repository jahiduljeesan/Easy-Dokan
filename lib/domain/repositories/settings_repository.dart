import '../../data/models/settings_model.dart';

abstract class SettingsRepository {
  SettingsModel getSettings();
  Future<void> saveSettings(SettingsModel settings);
  Future<void> updateTheme(bool isDarkTheme);
  Future<void> updateLanguage(String languageCode);
}
