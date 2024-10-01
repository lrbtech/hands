import 'package:flutter/material.dart';
import 'package:hands_user_app/provider/locale/base_language.dart';
import 'package:hands_user_app/provider/locale/language_ar.dart';
import 'package:hands_user_app/provider/locale/language_en.dart';
import 'package:nb_utils/nb_utils.dart';

class AppLocalizations extends LocalizationsDelegate<Languages> {
  const AppLocalizations();

  @override
  Future<Languages> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEng();
      case 'ar':
        return LanguageAra();
      default:
        return LanguageEng();
    }
  }

  @override
  bool isSupported(Locale locale) =>
      LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
