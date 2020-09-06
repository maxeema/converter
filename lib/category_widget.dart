import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'category.dart';
import 'extensions.dart';

const _fadeInDuration = 1500;
const _slideInDuration = 1500;

class CategoryWidget extends HookWidget {

  final Function(CategoryInfo catInfo) onSelect;
  final CategoryInfo catInfo;
  final bool placeIconToStart;
  final Duration appearanceDelay;
  final EdgeInsetsDirectional margin;

  const CategoryWidget({Key key, this.catInfo, this.onSelect,
                          this.placeIconToStart, this.appearanceDelay,
                            this.margin}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final fadeAni = useAnimationController(duration: _fadeInDuration.ms);
    final slideAni = useAnimationController(duration: _slideInDuration.ms);
    final isMounted = useIsMounted();
    useEffect(() {
      appearanceDelay.delay.then((_) {
        if (isMounted()) {
          fadeAni.forward();
          slideAni.forward();
        }
      });
      return null;
    });
    final tweenAni = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset.zero,
    )
    .animate(CurvedAnimation(
      parent: slideAni,
      curve: Curves.bounceInOut,
    ));
    return FadeTransition(
      opacity: slideAni,
      child: SlideTransition(
        position: tweenAni,
        child: Container(
          height: 100.0,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            highlightColor: Colors.white.withOpacity(0.1),
            splashColor: Colors.black,
            onTap: () => onSelect(catInfo),
            child: Container(
              margin: margin,
              padding: 8.insets.all,
              child: Row(
                  children: (){
                    Widget icon = WebsafeSvg.asset(
                        catInfo.category.icon,
                        width: 48,
                        color: catInfo.color
                    );
                    Widget title = Text(
                      catInfo.category.name,
                      maxLines: 2,
                      textAlign: placeIconToStart ? TextAlign.start : TextAlign.end,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.headline5.apply(
                        color: catInfo.color,
                      ),
                    );
                    final widgets = <Widget>[];
                    widgets.add(SizedBox(width: 16));
                    widgets.add(Expanded(flex: placeIconToStart ? 1 : 2,
                        child: placeIconToStart ? icon : title
                    ));
                    widgets.add(SizedBox(width: 24));
                    widgets.add(Expanded(flex: placeIconToStart ? 2 : 1,
                      child: placeIconToStart ? title : icon,
                    ));
                    widgets.add(SizedBox(width: 16));
                    return widgets;
                  }()
              ),
            ),
          ),
        ),
      ),
    );
  }
}