
import 'package:shared_preferences/shared_preferences.dart';

import 'category.dart';

const _keyCategory = "category";
const _keyGoofy = "goofy";

get prefs => SharedPreferences.getInstance();

loadCategory () async
    => (await prefs).getString(_keyCategory);
saveCategory(Category category) async
    => (await prefs).setString(_keyCategory, category.name);

loadGoofy () async
    =>(await prefs).getBool(_keyGoofy);
saveGoofy(bool selected) async
    => (await prefs).setBool(_keyGoofy, selected);
