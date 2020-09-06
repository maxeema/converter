
import 'package:flutter/material.dart';

import 'util.dart' as util;

class CategoryInfo {
  final Category category;
  final Color color;

  CategoryInfo(this.category, this.color);
}

class Category {

  final String name;
  final List<Unit> units;

  const Category(this.name, this.units)
      : assert(name != null), assert(units != null);

  get icon => "assets/icons/${name.replaceAll(' ', '_').toLowerCase()}.svg";

}

class Unit {

  final String name;
  final double conversion;
  final String description;
  final bool baseUnit;

  const Unit({
    @required this.name,
    @required this.conversion,
    @required this.description,
    @required this.baseUnit,
  })  : assert(name != null),
        assert(conversion != null);

  Unit.fromJson(Map j)
      : assert(j['name'] != null),
        assert(j['conversion'] != null),
        name = j['name'],
        conversion = j['conversion'].toDouble(),
        description = j['description'],
        baseUnit = j['baseUnit'];

  bool get hasDescription => !util.isEmpty(description);

  @override
  String toString() => name;

}
