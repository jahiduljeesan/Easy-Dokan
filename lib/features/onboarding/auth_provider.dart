import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/settings_model.dart';

final authStateProvider = StateProvider<bool>((ref) {
  final settingsBox = Hive.box<SettingsModel>('settings');
  final settings = settingsBox.get('app_settings');
  if (settings?.pinCode != null && settings!.pinCode!.isNotEmpty) {
    return false;
  }
  return true;
});
