import 'dart:io';
import 'package:flutter/material.dart';

class LocaleConstants {
  /// Get system language code
  static String defaultLanguage = Platform.localeName.substring(0, 2);

  /// Return saved locale
  static Locale getLocale() {
    return locale(defaultLanguage);
  }

  @visibleForTesting
  static Locale locale(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('en', 'US');
    }
  }
}