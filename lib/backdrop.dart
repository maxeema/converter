
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import 'about_dialog.dart';
import 'conf.dart' as conf;
import 'ext.dart';
import 'state.dart';

const _flingVelocity = 2.0;

class _BackdropPanel extends StatelessWidget {

  const _BackdropPanel({
    Key key,
    this.onTap,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
    Material(
      color: conf.backgroundColor,
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: onVerticalDragUpdate,
            onVerticalDragEnd: onVerticalDragEnd,
            onTap: onTap,
            child: Container(
              height: conf.backdropHeaderSize,
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

class _BackdropTitle extends AnimatedWidget {
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key key,
    Listenable listenable,
    this.frontTitle,
    this.backTitle,
  }) : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;
    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.title,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      // Here, we do a custom cross fade between backTitle and frontTitle.
      // This makes a smooth animation between the two texts.
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: CurvedAnimation(
              parent: ReverseAnimation(animation),
              curve: Interval(0.5, 1.0),
            ).value,
            child: backTitle,
          ),
          Opacity(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Interval(0.5, 1.0),
            ).value,
            child: frontTitle,
          ),
        ],
      ),
    );
  }
}

/// Builds a Backdrop.
///
/// A Backdrop widget has two panels, front and back. The front panel is shown
/// by default, and slides down to show the back panel, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back panel is showing.
class Backdrop extends StatefulWidget {

  final Widget frontPanel;
  final Widget backPanel;
  final Widget frontTitle;
  final Widget backTitle;

  Backdrop({
    @required this.frontPanel,
    @required this.backPanel,
    @required this.frontTitle,
    @required this.backTitle,
  }) : assert(frontPanel != null),
        assert(backPanel != null),
        assert(frontTitle != null),
        assert(backTitle != null);

  _BackdropState createState() {
    return _BackdropState();
  }

}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {

  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;

  AppState appState = GetIt.I.get<AppState>();

  @override
  void initState() {
    super.initState();
    appState.opened.addListener(onOpenedState);
    // This creates an [AnimationController] that can allows for animation for
    // the BackdropPanel. 0.00 means that the front panel is in "tab" (hidden)
    // mode, while 1.0 means that the front panel is open.
    _controller = AnimationController(
      duration: mil(300),
      value: 0,
      vsync: this,
    );
    _controller.addStatusListener(animationChanged);
  }
  animationChanged(AnimationStatus status) {
    print(status);
    if (status == AnimationStatus.dismissed) {
        appState.opened.value = false;
    }
  }
  onOpenedState() {
    if (appState.opened.value)
      _controller.animateTo(1);
    if (!appState.opened.value && _controller.status != AnimationStatus.dismissed)
      _controller.animateTo(0);
  }

  @override
  void dispose() {
    appState.opened.removeListener(onOpenedState);
    _controller.dispose();
    super.dispose();
  }

  bool get _backdropPanelVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropPanelVisibility() {
    _controller.fling(
        velocity: _backdropPanelVisible ? -_flingVelocity : _flingVelocity);
  }

  double get _backdropHeight {
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  // By design: the panel can only be opened with a swipe. To close the panel
  // the user must either tap its heading or the backdrop's menu icon.

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    _controller.value -= details.primaryDelta / _backdropHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(_flingVelocity, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-_flingVelocity, -flingVelocity));
    else
      _controller.fling(
          velocity:
          _controller.value < 0.5 ? -_flingVelocity : _flingVelocity);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double panelTitleHeight = conf.backdropHeaderSize;
    final Size panelSize = constraints.biggest;
    final double panelTop = panelSize.height - panelTitleHeight;

    Animation<RelativeRect> panelAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0, panelTop, 0.0, panelTop - panelSize.height),
      end: RelativeRect.fromLTRB(0.0, conf.backdropHeaderOffset, 0.0, 0.0),
    ).animate(_controller.view);

    return Container(
      key: _backdropKey,
      color: Theme.of(context).backgroundColor,
      child: Stack(
        children: <Widget>[
          widget.backPanel,
          PositionedTransition(
            rect: panelAnimation,
            child: _BackdropPanel(
              onTap: _backdropPanelVisible ? null : _toggleBackdropPanelVisibility,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              child: widget.frontPanel,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: ValueListenableBuilder<bool>(
          valueListenable: appState.opened,
          child: Center(child: Icon(Icons.menu)),
          builder: (ctx, opened, widget) {
            return AnimatedSwitcher(
              duration: mil(300),
              child: IconButton(
                icon: Opacity(opacity: opened ? 1 : 0.25, child: widget),
                onPressed: opened ? _toggleBackdropPanelVisibility : null,
              ),
            );
          },
        ),
//        leading: IconButton(
//          onPressed: _toggleBackdropPanelVisibility,
//          icon: AnimatedIcon(
//            icon: AnimatedIcons.close_menu,
//            progress: _controller.view,
//          ),
//        ),
        title: _BackdropTitle(
          listenable: _controller.view,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.info_outline, color: Colors.white54,),
            onPressed: ()=> showAbout(context)
          )
        ],
      ),
      body: LayoutBuilder(
        builder: _buildStack,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
