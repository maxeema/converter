
enum Units {
  goofy, standard
}

extension UnitsExt on Units {
  String get assetJson {
    switch(this) {
      case Units.goofy:    return 'assets/data/goofy_units.json';
      case Units.standard: return 'assets/data/standard_units.json';
    }
  }
  //
  int get precision => this == Units.goofy ? 7 : 2;
  //
  Units get next {
    final units = Units.values;
    return units.last == this ? units.first : units[units.indexOf(this)+1];
  }
}