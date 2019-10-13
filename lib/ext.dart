import 'package:flutter/material.dart';

///
/// Shortcuts
///

sec(value) => Duration(seconds: value);
mil(value) => Duration(milliseconds: value);

vert(double value) => EdgeInsets.symmetric(vertical: value);
horiz(double value) => EdgeInsets.symmetric(horizontal: value);

end(double value) => EdgeInsetsDirectional.only(end: value);
start(double value) => EdgeInsetsDirectional.only(start: value);

tb(double top, double bottom) => EdgeInsetsDirectional.only(top: top, bottom: bottom);
se(double start, double end) => EdgeInsetsDirectional.only(start: start, end: end);

top(double top) => EdgeInsetsDirectional.only(top: top);
bot(double bottom) => EdgeInsetsDirectional.only(bottom: bottom);

all(double value) => EdgeInsets.all(value);
steb(double start, double top, double end, double bottom) => EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);
