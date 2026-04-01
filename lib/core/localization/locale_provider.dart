import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Default to English, but could be loaded from shared_preferences
    return const Locale('en');
  }

  void setLocale(Locale locale) {
    state = locale;
  }
}
