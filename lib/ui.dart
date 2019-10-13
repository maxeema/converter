
import 'package:flutter/material.dart';

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
