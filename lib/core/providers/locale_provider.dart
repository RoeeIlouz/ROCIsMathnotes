import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  static const String _localeKey = 'locale';
  
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('he', ''), // Hebrew
  ];

  void _loadLocale() async {
    final box = await Hive.openBox('settings');
    final localeCode = box.get(_localeKey);
    if (localeCode != null) {
      state = Locale(localeCode);
    }
  }

  void setLocale(Locale locale) async {
    state = locale;
    final box = await Hive.openBox('settings');
    await box.put(_localeKey, locale.languageCode);
  }

  void toggleLanguage() {
    if (state?.languageCode == 'en') {
      setLocale(const Locale('he', ''));
    } else {
      setLocale(const Locale('en', ''));
    }
  }
  
  bool get isRTL => state?.languageCode == 'he';
  
  String get currentLanguageName {
    switch (state?.languageCode) {
      case 'he':
        return 'עברית';
      case 'en':
      default:
        return 'English';
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);

// Helper provider to check if current locale is RTL
final isRTLProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return locale?.languageCode == 'he';
});

// Helper provider to get text direction
final textDirectionProvider = Provider<TextDirection>((ref) {
  final isRTL = ref.watch(isRTLProvider);
  return isRTL ? TextDirection.rtl : TextDirection.ltr;
});