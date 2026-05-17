import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/local/hive_service.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'localization/app_localizations.dart';
import 'features/settings/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();

  runApp(const ProviderScope(child: EasyDokanApp()));
}

// Provider for locale
final localeProvider = Provider<Locale>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return Locale(settings.language);
});

// Provider for theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.isDarkTheme ? ThemeMode.dark : ThemeMode.light;
});

class EasyDokanApp extends ConsumerWidget {
  const EasyDokanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Easy Dokan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('en', ''), Locale('bn', '')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
