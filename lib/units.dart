
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
}