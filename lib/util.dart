
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'ext.dart';
import 'glob.dart' as glob;
import 'ui.dart';

bool isEmpty(String s) => s?.trim()?.isEmpty ?? true;

copyToClipboard(String text, BuildContext ctx, String toastMsg) {
  Clipboard.setData(ClipboardData(text: text));
//  print('Copied to clipboard: $text');
  if (toastMsg != null && ctx != null)
    toast(ctx, toastMsg);
}

showAbout(BuildContext context) =>
  PackageInfo.fromPlatform().then((PackageInfo info) {
    showAboutDialog(context: context,
        applicationIcon: SvgPicture.asset( glob.appIcon, width: 48 ),
        applicationName: info.appName,
        applicationVersion: info.version,
        applicationLegalese: glob.appLegalese,
        children: [
          RichText(
            textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.body1,
                children: [
                  TextSpan(text: '\nMade by taking '),
                  TextSpan(
                    text: 'Udacity course',
                    style: TextStyle(color: Theme.of(context).accentColor),
                    recognizer: TapGestureRecognizer()..onTap =
                        () => launcher.launch('https://www.udacity.com/course/build-native-mobile-apps-with-flutter--ud905')
                  ),
                  TextSpan(text:'\n\nApp '),
                  TextSpan(
                    text:'GitHub',
                    style: TextStyle(color: Theme.of(context).accentColor),
                    recognizer: TapGestureRecognizer()..onTap =
                        () => launcher.launch('https://github.com/maxeema/flutter-goofy-converter')
                  ),
                  TextSpan(text:' page')
                ]
              )
          ),
          Container(
            margin: top(16),
            alignment: Alignment.center,
            child: OutlineButton(
              textTheme: ButtonTextTheme.primary,
              child: Text('See on Google Play',),
              onPressed: () {
                print('launch https://play.google.com/store/apps/details?id=${info.packageName}');
                launcher.launch('https://play.google.com/store/apps/details?id=${info.packageName}');
              },
            )
          )
        ]
    );
  });