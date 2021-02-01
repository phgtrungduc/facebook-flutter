import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScaleAnimationRoute extends PageRouteBuilder {
  final Widget page;
  ScaleAnimationRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: Duration(milliseconds: 600),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(begin: 0,end: 1).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutExpo,
                reverseCurve: Curves.linear)),
            child: child,
          ),
        );
}
