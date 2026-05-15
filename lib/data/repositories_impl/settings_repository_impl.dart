import 'package:hive/hive.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(Hive.box<SettingsModel>('settings'));
});

class SettingsRepositoryImpl implements SettingsRepository {
  final Box<SettingsModel> _box;
  static const String _settingsKey = 'app_settings';

  SettingsRepositoryImpl(this._box);

  @override
  SettingsModel getSettings() {
    return _box.get(_settingsKey) ?? SettingsModel();
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    await _box.put(_settingsKey, settings);
  }

  @override
  Future<void> updateTheme(bool isDarkTheme) async {
    final settings = getSettings();
    settings.isDarkTheme = isDarkTheme;
    await saveSettings(settings);
  }

  @override
  Future<void> updateLanguage(String languageCode) async {
    final settings = getSettings();
    settings.language = languageCode;
    await saveSettings(settings);
  }
}
