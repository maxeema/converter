
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'conf.dart' as conf;
import 'localization.dart';
import 'util.dart' as util;

showAbout(BuildContext context) async {

  final localizations = AppLocalizations.of(context);
  final platform = Theme.of(context).platform;

  //
  String appName;
  String appVersion;

  PackageInfo packageInfo;
  try {
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    appVersion = packageInfo.version;
  } catch (e) {
    appName = localizations.appTitle;
    appVersion = kIsWeb ? "Web" : () {
      var name = platform.toString();
      name = name.substring(platform.toString().lastIndexOf(".")+1);
      return name.substring(0, 1).toUpperCase() + name.substring(1);
    }();
  }

  showAboutDialog(context: context,
      applicationIcon: SizedBox(
        width: 48, height: 48,
        child: Image.asset("assets/icon.png"),
      ),
      applicationName: appName,
      applicationVersion: appVersion,
      applicationLegalese: conf.appLegalese,
      children: [
        SizedBox(height: 8,),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.body1,
              children: [
                TextSpan(text: '\n'),
                ... util.spanzize(
                    localizations.madeByTaking, 'Udacity',
                        (nonMatched) => TextSpan(text: nonMatched),
                        (matched) => TextSpan(
                        text: matched,
                        style: TextStyle(color: conf.accentColor2),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => util.launchUrl(conf.appUdacityCourse)
                    ),
                ),
                TextSpan(text: '\n\n'),
                ... util.spanzize(
                  localizations.appGitHubPage, 'GitHub',
                    (nonMatched) => TextSpan(text: nonMatched),
                    (matched) => TextSpan(
                      text: matched,
                      style: TextStyle(color: conf.accentColor1),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => util.launchUrl(conf.appGithubPage)
                  )
                ),
              ],
            )
        ),
        Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: OutlineButton(
              textTheme: ButtonTextTheme.primary,
              child: Text(localizations.seeOnPlayStore),
              onPressed: () {
                util.launchUrl(conf.appPlayStoreUrl.replaceAll("%package%", packageInfo.packageName));
              },
            )
        ),
      ]
  );
}
