import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {

  @override
  bool isSupported(Locale locale) => {'en'}.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of AppLocalizations.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class AppLocalizations {

  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Flutter Converter',
      'conversion': 'Conversion',
      'enterValue': 'Enter value',
      'incorrectInput': 'Incorrect input',
      'seeOnPlayStore': 'See on Google Play',
      'appGitHubPage': 'App GitHub page',
      'madeByTaking': 'Made by taking Udacity course'
    },
  };

  Map<String, String> get _localized => _localizedValues[locale.languageCode];

  String get appTitle => _localized['title'];
  String get course => _localized['course'];
  String get conversion => _localized['conversion'];
  String get enterValue => _localized['enterValue'];
  String get incorrectInput => _localized['incorrectInput'];
  String get seeOnPlayStore => _localized['seeOnPlayStore'];
  String get appGitHubPage => _localized['appGitHubPage'];
  String get madeByTaking => _localized['madeByTaking'];

}
