import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class Translations {
  Translations(Locale locale) {
    this.locale = locale;
    _localizedValues = Map<dynamic, dynamic>();
    _localizedValues2 = Map<dynamic, dynamic>();
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;
  static Map<dynamic, dynamic> _localizedValues2;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String text(String key) {
    if (locale.languageCode == 'en') {
      return key;
    }
    return _localizedValues[key];
  }

  String text2(String key, [String defaultValue]) {
    return _localizedValues2[key] ?? text(key) ?? key;
  }

  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);

    if (globals.translation['translation_${locale.languageCode}.xml'] != null) {
      _localizedValues2 = XmlLoader().loadTranslationsXml(locale.languageCode);
    } else {
      try {
        Translations translations = new Translations(const Locale('en'));
        String jsonContent = await rootBundle.loadString("locale/i18n_de.json");
        _localizedValues = json.decode(jsonContent);

        return translations;
      } catch (e) {
        throw new Error();
      }
    }

    return translations;
  }

  get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}

class XmlLoader {
  xml.XmlDocument currentXml;

  XmlLoader();

  Map<String, String> loadTranslationsXml(String lang) {
    if (lang == 'en') {
      File file;
      String contents;

      if (globals.translation['translation.xml'] != null)
        file = new File(globals.translation['translation.xml']);

      if (file.existsSync()) {
        contents = file.readAsStringSync();
      } else {
        print('Error with Loading ${globals.translation["translation.xml"]}');
      }

      if (contents != null) {
        xml.XmlDocument doc = xml.parse(contents);

        Map<String, String> translations = <String, String>{};

        doc.findAllElements('entry').toList().forEach((e) {
          translations[e.attributes.first.value] = e.text;
        });

        return translations;
      }
    }
    if (globals.translation['translation_$lang.xml'] != null) {
      File file;
      String contents;

      file = new File(globals.translation['translation_$lang.xml']);

      if (file.existsSync()) {
        contents = file.readAsStringSync();
      } else {
        print('Error with Loading ${globals.translation["translation_" + lang + ".xml"]}');
      }
      
      xml.XmlDocument doc = xml.parse(contents);

      Map<String, String> translations = <String, String>{};

      doc.findAllElements('entry').toList().forEach((e) {
        translations[e.attributes.first.value] = e.text;
      });

      return translations;
    }
    return <String, String>{};
  }
}
