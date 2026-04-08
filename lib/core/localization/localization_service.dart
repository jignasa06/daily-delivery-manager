import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends GetxService {
  final _storage = GetStorage();

  static final locales = [
    const Locale('en', 'US'),
    const Locale('hi', 'IN'),
    const Locale('gu', 'IN'),
    const Locale('mr', 'IN'),
  ];

  static final langs = [
    'English',
    'Hindi',
    'Gujarati',
    'Marathi',
  ];

  Locale get locale => _loadLocale();

  void changeLocale(String lang) {
    final locale = _getLocaleFromLang(lang);
    Get.updateLocale(locale);
    _saveLocale(locale);
  }

  Locale _loadLocale() {
    final lang = _storage.read('lang');
    if (lang != null) {
      return _getLocaleFromLang(lang);
    }
    return Get.deviceLocale ?? LocalizationService.locales.first;
  }

  void _saveLocale(Locale locale) {
    _storage.write('lang', _getLangFromLocale(locale));
  }

  Locale _getLocaleFromLang(String lang) {
    int index = LocalizationService.langs.indexOf(lang);
    return LocalizationService.locales[index];
  }

  String _getLangFromLocale(Locale locale) {
    int index = LocalizationService.locales.indexWhere((l) => l.languageCode == locale.languageCode);
    return LocalizationService.langs[index];
  }

  String getCurrentLang() {
    return _getLangFromLocale(locale);
  }
}
