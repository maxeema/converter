
import 'package:converter/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import 'conf.dart';
import 'localization.dart';
import 'main_screen.dart';
import 'insets.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton(AppState());
  runApp(UnitConverterApp());
}

class UnitConverterApp extends HookWidget {

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      SystemChrome.setEnabledSystemUIOverlays([]);
      return null;
    }, ["onetime"]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: MainScreen()
          ),
          Container(
            padding: 10.insets.all,
            child: Text(appLegalese, style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 14,
              decoration: TextDecoration.none,
              color: accentColor5.withOpacity(.7)
            )),
          )
        ],
      ),
      //theme
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: backgroundColor,
        backgroundColor: backgroundColor,
        accentColor: accentColor5,
        fontFamily: 'Raleway',
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey.shade900,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey.shade900,
          contentTextStyle: Theme.of(context).textTheme.bodyText2.apply(
            color: Colors.white70
          )
        ),
      ),
      //localization
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [ Locale('en'), ],
    );
  }

}
