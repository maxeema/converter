import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension BuildContextExt on BuildContext {
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get iOS => Theme.of(this).platform == TargetPlatform.iOS;
}

// ignore: top_level_function_literal_block
final _empty = () {};

mixin StateMix<T extends StatefulWidget> on State<T> {
  var _disposed = false;
  bool get disposed => _disposed;
  @override void dispose() {
    _disposed = true;
    super.dispose();
  }
  updateState() {
    if (!_disposed)
      try { setState(() {}); } catch (e) { print(e); }
  }
  // showError(String msg, {String title}) => UiUtils.showMessage(this, msg, title: title);
  // applyAppBarStyle(UiOverlayStyle style) async {
  //   if (mounted && !_disposed) {
  //     style.apply();
  //     await 500.ms.delay;
  //     if (mounted && !_disposed)
  //       style.apply();
  //   }
  // }
}
extension StateExt<T extends StatefulWidget> on State<T> {
  justUpdateState([dynamic _ignored]) => updateStateChecked();
  updateStateChecked([VoidCallback fn]) {
    if (mounted)
      try { setState(fn ?? _empty); } catch (e) { print(e); }
  }
}

// extension VideoPlayerControllerExt on VideoPlayerController {
//   bool get isPlaying => value?.isPlaying == true;
// }
