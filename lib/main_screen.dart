
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'backdrop.dart';
import 'category.dart';
import 'conf.dart' as conf;
import 'converter.dart';
import 'ext.dart';
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
        if (opened)
          appState.opened.value = false;
        return Future.value(!opened);
      },
    );
  }
}

class _MainScreenWidget extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<_MainScreenWidget> {

  AppState appState = GetIt.I.get<AppState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: appState.categories,
      builder: (ctx, snap) {
        if (!snap.hasData)
          return Center(child: CircularProgressIndicator());
        return Backdrop(
          frontPanel: Converter(),
          backPanel: _buildCats(snap.data),
          frontTitle: Text(AppLocalizations.of(context).appTitle),
          backTitle: Text(AppLocalizations.of(context).appTitle),
        );
      }
    );
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

  _selectCategory(Category category) {
    appState.category.value = category;
    appState.opened.value = true;
  }

  _buildCats(List<Category> cats) {
    Widget list;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      list = Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: cats.map((cat) => Flexible(
          child: _buildCategoryWidget(cat, true)
        )).toList()
      );
    } else {
      list = GridView.count(
        crossAxisCount: _landscapeItemsCount,
        childAspectRatio: 3,
        children: () {
          final widgets = <Widget>[];
          for (int i=0; i<cats.length; i++) {
            widgets.add(_buildCategoryWidget(cats[i], i%_landscapeItemsCount==1));
          }
          return widgets.toList();
        }(),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Padding(
        child: list,
        padding: bot(conf.backdropHeaderSize),
      ),
    );
  }

  _buildCategoryWidget(Category category, bool iconToStart) =>
    Container(
      height: 100.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.black,
        onTap: () => _selectCategory(category),
        child: Padding(
          padding: all(8.0),
          child: Row(
          children: (){
            final icon = WebsafeSvg.asset(
              category.icon,
              width: 48,
              color: conf.accentColor1
            );
            final title = Text(
              category.name,
              maxLines: 2,
              textAlign: iconToStart ? TextAlign.start : TextAlign.end,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.headline5.apply(
                  color: conf.accentColor3
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
    );

}
