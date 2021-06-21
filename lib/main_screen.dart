import 'dart:convert';

import 'package:converter/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'backdrop.dart';
import 'category.dart';
import 'category_widget.dart';
import 'conf.dart' as conf;
import 'conf.dart';
import 'converter.dart';
import 'insets.dart';
import 'localization.dart';
import 'state.dart';

const _landscapeItemsCount = 2;

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: _MainScreenWidget(),
      onWillPop: () {
        final appState = GetIt.I.get<AppState>();
        final opened = appState.opened.value;
        if (opened) appState.opened.value = false;
        return Future.value(!opened);
      },
    );
  }
}

class _MainScreenWidget extends StatelessWidget {
  final appState = GetIt.I.get<AppState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
        future: appState.categories,
        builder: (ctx, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final cats = snap.data;
          return Backdrop(
            frontPanel: Converter(),
            backPanel: LayoutBuilder(
              builder: (ctx, constraints) {
                Widget list;
                var i = 0;
                if (MediaQuery.of(context).orientation == Orientation.portrait) {
                  list = Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: cats.map((cat) {
                        final idx = i++;
                        return Flexible(
                            child: CategoryWidget(
                                catInfo: CategoryInfo(cat, colors[idx % 2]),
                                onSelect: _selectCategory,
                                placeIconToStart: true,
                                appearanceDelay: Duration(milliseconds: i * 150),
                                // margin: idx.isOdd ? 60.insets.start : 0.insets.start
                                margin: 0.insets.start));
                      }).toList());
                } else {
                  list = GridView.count(
                    crossAxisCount: _landscapeItemsCount,
                    childAspectRatio: 3,
                    children: cats.map((cat) {
                      final idx = i++;
                      return CategoryWidget(
                        catInfo: CategoryInfo(cat, colors[idx % 2]),
                        onSelect: _selectCategory,
                        placeIconToStart: idx % _landscapeItemsCount == 1,
                        appearanceDelay: Duration(milliseconds: idx * 100),
                      );
                    }).toList(),
                  );
                }
                return Material(
                  color: Colors.transparent,
                  child: Container(
                    color: Colors.transparent,
                    padding: conf.backdropHeaderSize.toInt().insets.bot,
                    child: list,
                  ),
                );
              },
            ),
            frontTitle: ValueListenableBuilder<bool>(
              valueListenable: appState.opened,
              builder: (context, opened, widget) {
                return InkWell(
                  onTap: opened
                      ? () => appState.opened.value = false
                      : null,
                  child: Visibility(visible: opened, child: widget),
                );
              },
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios)),
                  Text(AppLocalizations.of(context).appTitle),
                ],
              ),
            ),
            backTitle: FutureBuilder<Object>(
                future: Future.delayed(1000.ms, () => 'ok'),
                builder: (context, snapshot) {
                  return AnimatedSwitcher(
                    duration: 1000.ms,
                    child: Row(
                      key: ValueKey(snapshot.hasData),
                      children: [
                        Opacity(opacity: 0, child: IconButton(icon: Icon(Icons.arrow_back_ios))),
                        Text(
                          snapshot.hasData ? AppLocalizations.of(context).appTitle : ' ',
                        )
                      ],
                    ),
                  );
                }),
          );
        });
  }

//  Future<void> _fetchApiCategories() async {
//    final api = Api();
//    print("retrieve Api Category, await units");
//
//    final jsonUnits = await api.getUnits(apiCurrencyCategory['route']);
//    print("retrieve Api Category, complete: $jsonUnits");
//
//    if (jsonUnits != null) {
//      final units = jsonUnits.map((unit) => Unit.fromJson(unit)).toList();
//      setState(() {
//        _categories.add(Category(apiCurrencyCategory['name'], units));
//      });
//    }
//  }

  _selectCategory(CategoryInfo category) {
    appState.catInfo.value = category;
    appState.opened.value = true;
  }
}
