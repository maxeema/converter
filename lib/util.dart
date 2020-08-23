
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'ui.dart';

bool isEmpty(String s) => s?.trim()?.isEmpty ?? true;

copyToClipboard(String text, BuildContext ctx, String toastMsg) {
  Clipboard.setData(ClipboardData(text: text));
//  print('Copied to clipboard: $text');
  if (toastMsg != null && ctx != null)
    toast(ctx, toastMsg);
}

launchUrl(String url) {
  print(url);
  launcher.launch(url);
}

List<TextSpan>
spanzize(String text, String pattern,
    TextSpan nonMatchBuild(nonMatched),
    TextSpan matchBuild(matched)) {

  final idx = text.indexOf(pattern);
  final String before = idx > 0 ? text.substring(0, idx) : null;
  final String after = idx + pattern.length < text.length  ? text.substring(idx + pattern.length) : null;

  return <TextSpan>[
    if (before?.isNotEmpty ?? false)
      nonMatchBuild(before),
    matchBuild(pattern),
    if (after?.isNotEmpty ?? false)
      nonMatchBuild(after),
  ];
}
