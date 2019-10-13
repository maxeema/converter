// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import '../lib/category.dart';
import '../lib/prefs.dart' as prefs;

final _catName = "Digital";
final _catJson = Unit.fromJson({
  "name": _catName,
  "conversion": 1.0,
  "description": "This was considered a lot of space back in the day.",
  "base_unit": true
});


void main() {
  final category = Category(_catName, [_catJson]);
  group("Prefs", () {
    test('switch category and save as ${category.name}', () async {
      expect(await prefs.saveCategory(category), category.name);
    });
    test('load category and await for $_catName', () async {
      expect(await prefs.loadCategory(), _catName);
    });
  });
}
