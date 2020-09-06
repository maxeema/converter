// import 'dart:convert';

// import 'package:crypto/crypto.dart';

extension IntExt on int {
  Duration get  ms => Duration(milliseconds: this);
  Duration get sec => Duration(seconds: this);
}

extension DurationExt on Duration {
  Future get delay => Future.delayed(this);
}

extension StringExt on String {
  String fromAssets() => 'assets/$this';

  String repeat(int times, {String separator = ""})
      => List.filled(times, this).join(separator);

  String substringAfter(String str) => substring(indexOf(str) + str.length);

  // String toMD5() {
  //   final enc = utf8.encode(this);
  //   return md5.convert(enc).toString();
  // }
}

extension ListExt<T> on List<T> {
  int get lastIndex => length - 1;
  int get size => length;
  void addFirst(T t) => insert(0, t);
  List<T> toUnmodified() => List.unmodifiable(this);
}

extension StringMarkdownLinksExt on String {
//  static final markdownLinkRegexp = RegExp("\\[[^\\(]+\\]\\s*\\([^\\[]+\\)");
  static final markdownLinkRegexp = RegExp("\\[.+?\\]\\s*\\([^\\[]+\\)");
  static final _keyStart = '[', _keyEnd = ']';
  static final _valueStart = '(', _valueEnd = ')';

  String withMarkdownKey() => _withMarkdown(this, _keyStart, _keyEnd);
  String withMarkdownValue() => _withMarkdown(this, _valueStart, _valueEnd);

  static String _withMarkdown(String str, String start, String end) {
    while (markdownLinkRegexp.hasMatch(str)) {
      final match = markdownLinkRegexp.firstMatch(str);
      final sub = str.substring(match.start, match.end);
      str = str.replaceRange(match.start, match.end, sub.substring(sub.lastIndexOf(start)+1, sub.lastIndexOf(end)));
    }
    return str;
  }

}
