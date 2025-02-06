import 'package:intl/intl.dart';

class Strings {
  static const String chooseLanguage = 'chooseLanguage';

  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'chooseLanguage': 'Choose your language',
    },
    'es': {
      'chooseLanguage': 'Elige tu idioma',
    },
    'fr': {
      'chooseLanguage': 'Choisissez votre langue',
    },
  };

  static String get chooseLanguageText {
    return localizedValues[Intl.defaultLocale]?[chooseLanguage] ?? 'Choose your language';
  }
}
