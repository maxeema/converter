// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'api.dart';
import 'backdrop.dart';
import 'category.dart';
import 'converter.dart';
import 'ext.dart';
import 'glob.dart' as glob;
import 'localization.dart';
import 'prefs.dart' as prefs;

const _landscapeItemsCount = 2;

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {

  Category _defaultCategory;
  Category _currentCategory;
  final _categories = <Category>[];
  final _categoryNotifier = ChangeNotifier();

  @override
  void initState() {
    super.initState();
    if (_categories.isEmpty) {
      _processLocalCategories();
      // now, Api just fetches mock currencies
//      _fetchApiCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    //still loading
    if (_defaultCategory == null) {
      return Container(color: Theme.of(context).backgroundColor);
    }

    // Based on the device size, figure out how to best lay out the list
    assert(debugCheckHasMediaQuery(context));

    final category = _currentCategory ?? _defaultCategory;
    return Backdrop(
      categoryNotifier: _categoryNotifier,
      category: category,
      frontPanel: Converter(category),
      backPanel: _buildCategoryWidgets(),
      frontTitle: Text(AppLocalizations.of(context).title),
      backTitle: Text(AppLocalizations.of(context).selectCategory),
    );
  }

  Future<void> _processLocalCategories() async {
    final lastCategory = await prefs.loadCategory();
    final json = DefaultAssetBundle.of(context).loadString(glob.unitsFile);
    final data = JsonDecoder().convert(await json);

    if (data is! Map) {
      throw ('Data retrieved from API is not a Map');
    }

    for (String key in data.keys) {
      final category = Category(
          key, data[key].map<Unit>((raw) => Unit.fromJson(raw)).toList()
      );

      _categories.add(category);

      if (_defaultCategory == null && category.name == lastCategory) {
        setState(() {
          _defaultCategory = category;
        });
      }
    }

    if (_defaultCategory == null)
     setState(() {
      _defaultCategory = _categories.first;
     });
  }

  Future<void> _fetchApiCategories() async {
    final api = Api();
    print("retrieve Api Category, await units");

    final jsonUnits = await api.getUnits(apiCurrencyCategory['route']);
    print("retrieve Api Category, complete: $jsonUnits");

    if (jsonUnits != null) {
      final units = jsonUnits.map((unit) => Unit.fromJson(unit)).toList();
      setState(() {
        _categories.add(Category(apiCurrencyCategory['name'], units));
      });
    }
  }

  _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
      prefs.saveCategory(category);
      _categoryNotifier.notifyListeners();
    });
  }

  _buildCategoryWidgets() {
    Widget list;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      list = ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (ctx, idx) => _buildCategoryWidget(_categories[idx], true)
      );
    } else {
      list = GridView.count(
        crossAxisCount: _landscapeItemsCount,
        childAspectRatio: 3,
        children: () {
          final widgets = <Widget>[];
          for (int i=0; i<_categories.length; i++) {
            widgets.add(_buildCategoryWidget(_categories[i], i%_landscapeItemsCount==1));
          }
          return widgets.toList();
        }(),
      );
    }
    return Padding(
      child: list,
      padding: bot(glob.backdropHeaderSize),
    );
  }

  _buildCategoryWidget(Category category, bool iconToStart) =>
    Material(
      color: Colors.transparent,
      child: Container(
        height: 100.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Theme.of(context).primaryColor,
          onTap: () => _onCategoryTap(category),
          child: Padding(
            padding: all(8.0),
            child: Row(
            children: (){
              final icon = SvgPicture.asset(
                category.icon,
                width: 48,
                color: Colors.black87
              );
              final title = Text(
                category.name,
                maxLines: 2,
                textAlign: iconToStart ? TextAlign.start : TextAlign.end,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.headline.apply(
                    color: Colors.black87
                ),
              );
              final widgets = <Widget>[];
              widgets.add(SizedBox(width: 16));
              widgets.add(Expanded(flex: iconToStart ? 1 : 2,
                child: iconToStart ? icon : title
              ));
              widgets.add(SizedBox(width: 24));
              widgets.add(Expanded(flex: iconToStart ? 2 : 1,
                child: iconToStart ? title : icon,
              ));
              widgets.add(SizedBox(width: 16));
              return widgets;
              }()
            ),
          ),
        ),
      ),
    );

}