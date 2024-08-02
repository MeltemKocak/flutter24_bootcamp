import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationChecker {
  static changeLanguage(BuildContext context) {
    Locale? currentLocale = EasyLocalization.of(context)!.currentLocale;

    if (currentLocale == const Locale('en', 'US')) {
      EasyLocalization.of(context)!.setLocale(const Locale('tr', 'TR'));
    } else if (currentLocale == const Locale('tr', 'TR')) {
      EasyLocalization.of(context)!.setLocale(const Locale('de', 'DE'));
    } else if (currentLocale == const Locale('de', 'DE')) {
      EasyLocalization.of(context)!.setLocale(const Locale('es', 'ES'));
    } else if (currentLocale == const Locale('es', 'ES')) {
      EasyLocalization.of(context)!.setLocale(const Locale('fr', 'FR'));
    } else if (currentLocale == const Locale('fr', 'FR')) {
      EasyLocalization.of(context)!.setLocale(const Locale('zh', 'CN'));
    } else if (currentLocale == const Locale('zh', 'CN')) {
      EasyLocalization.of(context)!.setLocale(const Locale('ru', 'RU'));
    } else if (currentLocale == const Locale('ru', 'RU')) {
      EasyLocalization.of(context)!.setLocale(const Locale('ja', 'JP'));
    } else if (currentLocale == const Locale('ja', 'JP')) {
      EasyLocalization.of(context)!.setLocale(const Locale('hi', 'IN'));
    } else {
      EasyLocalization.of(context)!.setLocale(const Locale('en', 'US'));
    }
  }
}
