
import 'package:flutter/material.dart';

import 'glob.dart' as glob;
import 'util.dart' as util;

class Category {

  final String name;
  final List<Unit> units;

  const Category(this.name, this.units)
      : assert(name != null), assert(units != null);

  get icon => glob.iconsPath(name);

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

  Unit.fromJson(Map jsonMap)
      : assert(jsonMap['name'] != null),
        assert(jsonMap['conversion'] != null),
        name = jsonMap['name'],
        conversion = jsonMap['conversion'].toDouble(),
        description = jsonMap['description'],
        baseUnit = jsonMap['baseUnit'];

  bool get hasDescription => !util.isEmpty(description);

}