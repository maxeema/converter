
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'category.dart';
import 'units.dart';

class AppState {

  final units = ValueNotifier(Units.standard);
  final catInfo = ValueNotifier<CategoryInfo>(null);
  final opened = ValueNotifier(false);
  final input = ValueNotifier("");

  Future<List<Category>> _categories;
  Future<List<Category>> get categories => _categories;

  AppState() {
    _categories = () async {
      final json = await rootBundle.loadString(Units.standard.assetJson);
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data.keys.map((name) {
        return Category(
          name, (data[name] as List<dynamic>).map((raw) => Unit.fromJson(raw)).toList()
        );
      }).toList();
    }();
  }

}
