
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'category.dart';
import 'units.dart';
import 'ext.dart';
import 'conf.dart' as conf;
import 'localization.dart';
import 'state.dart';
import 'ui.dart' as ui;
import 'util.dart';

const _inputMaxLength = 127;

class Converter extends StatefulWidget {

  @override
  _ConverterState createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {

  AppState appState = GetIt.I.get<AppState>();

  CategoryInfo get catInfo => appState.catInfo.value;
  Category get category => catInfo?.category;

  final _textController = TextEditingController();
  TextSelection _textSelection;

  Unit _valueFrom,
       _valueTo;
  double _inputValue;
  String _inputValueStr = '',
         _convertedValue = '';
  bool _isEmptyInput = true,
       _isInputError = false;

  FocusNode _focusNode;

  @override
  initState() {
    super.initState();
    appState.catInfo.addListener(onCategoryChanged);
    _focusNode = FocusNode();
  }
  @override
  dispose() {
    appState.catInfo.removeListener(onCategoryChanged);
    _focusNode.dispose();
    super.dispose();
  }
  onCategoryChanged() {
    _setDefaults();
  }
  _setDefaults() {
    _valueFrom = category.units[0];
    _valueTo = category.units[1];
    _resetState();
    setState(() {});
  }

  _resetState() {
    _isEmptyInput = true;
    _isInputError = false;
    _inputValue = 0;
    _inputValueStr = '';
    _convertedValue = '';
    _textSelection = TextSelection.collapsed(offset: 0);
  }

  String _formatConversion(double value) {
    if (value == null)
      return double.nan.toString();
    // var outputNum = value.toStringAsPrecision(appState.units.value.precision);
    var outputNum = value.toStringAsFixed(appState.units.value.precision);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  _updateConversion() {
    _focusNode.requestFocus();
    if (_isEmptyInput || _isInputError) return;

    setState(() {
      _convertedValue = _formatConversion(
          _inputValue * (_valueTo.conversion / _valueFrom.conversion));
    });
  }

  _swapInput() {
    setState(() {
      final _toValueRef = _valueTo;
      _valueTo = _valueFrom;
      _valueFrom = _toValueRef;
      final _convertedValueRef = _convertedValue;
      _convertedValue = _formatConversion(double.tryParse(_inputValueStr)) ?? _inputValueStr;
      _inputValueStr = _convertedValueRef;
      _inputValue = double.tryParse(_inputValueStr) ?? double.nan;
      if (_inputValue != null && !_inputValue.isFinite)
        _convertedValue = _inputValueStr;
      _textSelection = null;
    });
  }

  _updateInput(String input) {
    appState.input.value = input;
    setState(() {
      if (input?.isEmpty ?? true) {
        _resetState();
        return;
      }
      _inputValueStr = input;
      _isEmptyInput = false;
      _isInputError = false;
      try {
        _inputValue = double.parse(input);
        _updateConversion();
      } on Exception catch (e) {
        _isInputError = true;
        _convertedValue = '';
      }
    });
  }

  _getUnitByName(String name) =>
      category.units.firstWhere((unit) => unit.name == name);

  _updateConversionFrom(dynamic unitName) {
    setState(() {
      _valueFrom = _getUnitByName(unitName);
    });
    _updateConversion();
  }

  _updateConversionTo(dynamic unitName) {
    setState(() {
      _valueTo = _getUnitByName(unitName);
    });
    _updateConversion();
  }

  bool b = false;

  @override
  Widget build(BuildContext context) {
    if (category == null)
      return SizedBox.shrink();

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    _textController.value = TextEditingValue(
        text: _inputValueStr,
        selection: TextSelection.collapsed(
            offset: _textSelection?.baseOffset ?? _inputValueStr.length));

    final input = TextField(
      focusNode: _focusNode,
      controller: _textController,
      scrollPadding: horiz(16),
      readOnly: true,
      showCursor: true,
      autofocus: true,
      textAlign: TextAlign.center,
      cursorColor: Colors.white.withOpacity(.7),
      style: Theme.of(context).textTheme.headline3.apply(
        color: _isInputError ? Colors.red.shade500 : Colors.white.withOpacity(.85),
        fontSizeFactor: 0.8,
      ),
      keyboardType: TextInputType.number,
      onChanged: _updateInput,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).enterValue,
        hintStyle: Theme.of(context).textTheme.title.apply(
            fontSizeFactor: 1.2,
            color: Colors.white.withOpacity(.7)
        ),
//        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
//        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
      ),
    );

    Future.delayed(sec(1), _focusNode.requestFocus);

    final isSwapEnabled = !_isInputError;
    final swapBtn = InkResponse(
      radius: 36,
      onTap: isSwapEnabled ? _swapInput : null,
      child: Padding(
        padding: steb(32, 8, 32, 8),
        child: Icon(isLandscape ? Icons.swap_horiz : Icons.swap_vert,
            size: 24, color: isSwapEnabled ? Colors.white70 : Colors.white30),
      )
    );

    Widget outputText = Text(
      isEmpty(_convertedValue) ? AppLocalizations.of(context).conversion : _convertedValue,
      textAlign: TextAlign.center,
      overflow: TextOverflow.fade,
      style: Theme.of(context).textTheme.display1.apply(
        fontSizeFactor:
        _isInputError || isEmpty(_convertedValue) ? .7 : 1,
        color: _isInputError || isEmpty(_convertedValue)
            ? conf.accentColor1.withAlpha(0x99)
            : conf.accentColor1,
      )
    );
    final output = AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(child: child, opacity: animation);
      },
      child: InkResponse(
        radius: 66,
        key: ValueKey(_inputValueStr),
        onTap: _isInputError || _isEmptyInput ? null : () {},
        onLongPress: _isInputError || _isEmptyInput ? null : () {
          copyToClipboard(_convertedValue, context, 'Copied!');
        },
        child: outputText
      ),
    );

    if (!isLandscape) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _createTitle(isLandscape),
          ),
          Expanded(
            flex: 7,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children:[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: horiz(32),
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              _createDropdown(_valueTo, true, isLandscape, _updateConversionTo),
                            ]
                          ),
                          TableRow(
                            children: [
                              Padding(
                                child: Divider(height: 1, thickness: 1, color: Colors.white12),
                                padding: bot(8),
                              )
                            ]
                          ),
                          TableRow(
                            children: [
                              output,
                            ]
                          ),
                        ],
                      ),
                    )
                  ),
                  Expanded(
                    child: Padding(padding: horiz(32),
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Table(
                          children: [
                            TableRow(
                                children: [
                                  input,
                                ]
                            ),
                            TableRow(
                                children: [
                                  _createDropdown(_valueFrom, false, isLandscape, _updateConversionFrom)
                                ]
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  ],
                ),
                swapBtn,
              ]
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                Expanded(flex: 2, child: SizedBox()),
                Expanded(flex: 20, child: ui.toFittedBox(_createKeyboard())),
                Expanded(flex: 1, child: SizedBox()),
              ],
            ),
          ),
        ]
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 16),
                      Expanded(
                        child: _createDropdown(_valueTo, true, isLandscape, _updateConversionTo),
                      ),
                      swapBtn,
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: end(16),
                    child: _createDropdown(_valueFrom, false, isLandscape, _updateConversionFrom),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 16),
                      Expanded(child: output),
                      Padding(
                        padding: horiz(16),
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          size: 24,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  )
                ),
                Expanded(
                  child:Row(
                    children: <Widget>[
                      Expanded(flex: 5, child: input),
                      SizedBox(width: 16),
                    ],
                  )
                )
              ],
            )
          ),
          Expanded(
            flex: 8,
            child: Row(
              children: <Widget>[
                SizedBox(width: 16),
                Expanded(flex: 5, child:  ui.toFittedBox(_createTitle(isLandscape), BoxFit.fitWidth)),
                SizedBox(width: 30),
                Expanded(flex: 7, child: ui.toFittedBox(_createKeyboard(),)),
              ],
            )
          ),
          Expanded(flex: 1, child: SizedBox()),
        ]
      );
    }
  }

  _createTitle(bool isLandscape) {
    if (!isLandscape) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 8,),
          Expanded(
            flex:1,
            child: _IconRotationWidget(category.icon, catInfo.color),
          ),
          SizedBox(
            width: 24,
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkResponse(
                radius: 40,
                onTap: () {
                  appState.opened.value = false;
                },
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.display2.apply(
                    color: Colors.white.withAlpha(0x99),
                  ),
                  child: ui.toFittedBox(
                    Text(
                      category.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: catInfo.color,
                      ),
                    )
                  )
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 8,
          ),
          _IconRotationWidget(category.icon, catInfo.color),
          SizedBox(
            width: 48,
          ),
          InkResponse(
            radius: 40,
            onTap: () {
              appState.opened.value = false;
            },
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.display2.apply(
                color: Colors.white70,
              ),
              child: Text(
                category.name,
                style: TextStyle(fontWeight: FontWeight.w200),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
        ],
      );
    }
  }

  _createDropdown(Unit unit, isTo, bool isLandscape, ValueChanged onChanged)
    => InkWell(
      onTap: () {},
      onLongPress: unit.hasDescription ? () {
        ui.showSnack(context, unit.description, 5);
      }: null,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: DropdownButton(
          underline: SizedBox(),
          key: ValueKey(unit.name),
          value: unit.name,
          isExpanded: true,
          onChanged: onChanged,
          icon: SizedBox(),
          selectedItemBuilder: (context) =>
            List.of(category.units.map((unit) {
              final icon = Icon(
                isLandscape ? Icons.arrow_drop_down
                  : isTo ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: Colors.white60
              );
              final text = Text(unit.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.subhead.apply(
                  color: Colors.white.withAlpha(0xdd),
                )
              );
              final row = Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                  isLandscape && isTo
                    ? <Widget>[text, icon,] : [icon, text],
              );
              return Center(child: row);
            })
          ),
          items: List.of(category.units.map((unit) {
            return DropdownMenuItem(
              value: unit.name,
              child: Center(
                child: Text(
                  unit.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.subhead,
                ),
              ));
          }
        )
      )),
    ),
  );

//  _createDropdown(Unit unit, isTo, bool isLandscape, ValueChanged onChanged)
//  => InkWell(
//    onTap: () {
//      final newUnit = category.units.last == unit
//          ? category.units.first
//          : category.units[category.units.indexOf(unit)+1];
//      onChanged(newUnit.name);
//    },
//    onLongPress: unit.hasDescription ? () {
//      ui.showSnack(context, unit.description, 5);
//    }: null,
//    child: CupertinoPicker(
//      scrollController: FixedExtentScrollController(initialItem: category.units.indexOf(unit)),
//      key: ValueKey(unit.name),
//      itemExtent: 50,
//      looping: true,
//      children: category.units.map((item) => Center(
//        child: Text(
//          item.name,
//          overflow: TextOverflow.fade,
//          style: Theme.of(context).textTheme.subtitle1.copyWith(
//              fontWeight: unit == item ? FontWeight.bold : FontWeight.normal,
//              color: Colors.white70
//          ),
//        ),
//      )).toList(),
//      onSelectedItemChanged: (int value) {
//        onChanged(category.units[value].name);
//      },
//    ),
//  );

  _clearInput() {
    _updateInput("");
    _focusNode.requestFocus();
  }

  _onKeyboardTap(String value) {
    switch (value) {
      case "<":
        _processBackspace();
        break;
      default:
        _processInsert(value);
    }
    _focusNode.requestFocus();
  }

  _processInsert(final value) {
    if (_inputValueStr.length >= _inputMaxLength) return;
    final s = _textController.selection;
    _textSelection = TextSelection.collapsed(offset: s.baseOffset + value.length);
    _updateInput(s.textBefore(_inputValueStr) + value + s.textAfter(_inputValueStr));
  }

  _processBackspace() {
    final s = _textController.selection;
    if (_isEmptyInput)
      return;
    if (_inputValueStr.contains('Infinity') || _inputValueStr.contains('NaN')) {
      _clearInput();
      return;
    }
    final bef = s.textBefore(_inputValueStr);
    final aft = s.textAfter(_inputValueStr);
    if (s.end - s.start > 0) {
      //clear selection
      _textSelection = TextSelection.collapsed(offset: s.baseOffset);
      _updateInput(bef + aft);
    } else if (s.baseOffset == 0) {
      //move cursor back
      setState(() {
        _textSelection = TextSelection.collapsed(offset: _inputValueStr.length);
      });
    } else {
      //remove before cursor
      final removeLength = bef.endsWith('e+') || bef.endsWith('e-') ? 2 : 1;
      _textSelection = TextSelection.collapsed(offset: max(0, s.baseOffset - removeLength));
      _updateInput((bef.isEmpty ? '' : bef.substring(0, bef.length - removeLength)) + aft);
    }
  }

  _createKeyboard() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
            _createButton("1"),
            _createButton("2"),
            _createButton("3"),
            _createBackspaceButton("<", Icons.backspace),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _createButton("4"),
            _createButton("5"),
            _createButton("6"),
            _createButton(_specialButtonText.isEmpty ? ' ': ".", color: Color(0xffdfdfdf)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _createButton("7"),
            _createButton("8"),
            _createButton("9"),
            _createButton("0"),
          ],
        ),
      ],
    );

    _createBackspaceButton(String char, IconData icon) => InkResponse(
        radius: 64,
        onTap: () => _onKeyboardTap(char),
        onLongPress: _isEmptyInput ? null : _clearInput,
        child: FlatButton(
          padding: tb(12, 8),
          child: Icon(icon, color: Colors.white60, size: 20,),
        ));

  _createButton(String char, {Color color = conf.accentColor2}) => InkResponse(
    radius: 64,
    onTap: char == ' ' ? null : () => char == '.' ? _onKeyboardTap('.') : _onKeyboardTap(char),
    child: FlatButton(
      padding: vert(8),
      child: Text(
        char == '.' ? _specialButtonText : char,
        style: Theme.of(context).textTheme.headline
        .copyWith(
          // fontWeight: FontWeight.w200,
          color: color,
        ).apply(
          fontSizeFactor: 1.25,
        ),
      )),
    onLongPress: char == '.' ? _onSpecialLongPress : null,
    onDoubleTap: char == '.' ? _onSpecialDoubleTap : null,
  );

  String get _specialButtonText => !(_inputValue?.isFinite ?? false) || _isInputError ? '' : '.e';

  _onSpecialLongPress() => _onKeyboardTap('e+1');
  _onSpecialDoubleTap() => _onKeyboardTap('e-1');

}

class _IconRotationWidget extends StatefulWidget {

  final String icon;
  final Color color;
  const _IconRotationWidget(this.icon, this.color);

  @override
  _IconRotationState createState() => _IconRotationState();

}

class _IconRotationState extends State<_IconRotationWidget>
    with SingleTickerProviderStateMixin {

  AnimationController _controller;
  String _icon;

  _animate() {
    _controller.value = 0;
    _controller.animateTo(
        1, duration: sec(1), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.icon != _icon) {
      _animate();
      _icon = widget.icon;
    }
    return RotationTransition(
      turns: _controller,
      child: GestureDetector(
          onTap: _animate,
          child: WebsafeSvg.asset(
            widget.icon,
            width: 48,
            color: widget.color,
          )
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}
