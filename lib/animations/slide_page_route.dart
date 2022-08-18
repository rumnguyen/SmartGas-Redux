import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String slideTo;

  /*
    + slideTo has one of these values: left, top, right, bottom
    + Reference: https://medium.com/flutter-community/everything-you-need-to-know-about-flutter-page-route-transition-9ef5c1b32823
  */

  SlidePageRoute({
    required this.page,
    this.slideTo = 'left',
  })  : assert(slideTo.compareTo('left') == 0 ||
            slideTo.compareTo('top') == 0 ||
            slideTo.compareTo('right') == 0 ||
            slideTo.compareTo('bottom') == 0),
        super(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin;
              var end = Offset.zero;

              switch (slideTo) {
                case 'left':
                  begin = Offset(1.0, 0.0);
                  break;
                case 'top':
                  begin = Offset(0.0, 1.0);
                  break;
                case 'right':
                  begin = Offset(-1.0, 0.0);
                  break;
                case 'bottom':
                  begin = Offset(0.0, -1.0);
                  break;
              }

              return SlideTransition(
                position: Tween<Offset>(
                  begin: begin,
                  end: end,
                ).animate(animation),
                child: child,
              );
            });
}
