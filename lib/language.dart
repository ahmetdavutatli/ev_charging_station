import 'package:flutter/cupertino.dart';

class Language{
  final int id;
  final String name;
  final String flag;
  final String languageCode;

  Language(this.id, this.name, this.flag, this.languageCode);

  static List<Language> languageList(){
    return <Language>[
      Language(1, 'English', '🇺🇸', 'en'),
      Language(2, 'Türkçe', '🇹🇷', 'tr'),
    ];
}

}

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = Locale('en', ''); // Default language

  Locale get currentLocale => _currentLocale;

  void changeLanguage(Locale newLocale) {
    _currentLocale = newLocale;
    notifyListeners();
  }
}