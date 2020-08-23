
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ext.dart';

showSnack(BuildContext context, msg, duration) =>
  Scaffold.of(context)
  ..removeCurrentSnackBar()
  ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: msg is String ? Text(msg) : msg,
      duration: duration is int ? sec(duration) : duration
    ),
  );

toFittedBox(Widget widget, [ fit = BoxFit.scaleDown]) =>
  FittedBox(
    child: widget,
    fit: fit,
  );

toast(BuildContext ctx, String msg) {
  final theme = Theme.of(ctx);
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white.withAlpha(0xdd),
      textColor: Colors.black87,
      fontSize: theme.accentTextTheme.bodyText2.fontSize
  );
}
