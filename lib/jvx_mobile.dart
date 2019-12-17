import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jvx_mobile_v3/ui/page/settings_page.dart';
import 'package:jvx_mobile_v3/ui/page/startup_page.dart';
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class JvxMobile extends StatelessWidget {
  bool loadConf;
  ThemeData theme;

  JvxMobile(this.loadConf, this.theme);

  MaterialApp materialApp(ThemeData theme) => MaterialApp(
        title: 'JVx Mobile',
        theme: theme,
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        //home: StartupPage(),
        localizationsDelegates: [
          const TranslationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [const Locale("en", "US"), const Locale("de", "DE")],
        initialRoute: '/',
        routes: {
          '/': (context) => StartupPage(this.loadConf),
          '/settings': (context) => SettingsPage(),
        },
      );

  @override
  Widget build(BuildContext context) {
    return materialApp(this.theme);
  }
}
