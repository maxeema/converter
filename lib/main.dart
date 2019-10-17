
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'glob.dart';
import 'localization.dart';
import 'main_screen.dart';

main() => runApp(UnitConverterApp());

class UnitConverterApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      //theme
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: appColor,
        primaryColor: appColor.shade700,
        backgroundColor: appColor.shade300,
        accentColor: Colors.blue,
        fontFamily: 'Raleway',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey.shade900,
          contentTextStyle: Theme.of(context).textTheme.body1.apply(
            color: Colors.white70
          )
        ),
      ),
      //localization
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).title,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [ Locale('en', ''),],
    );

}
