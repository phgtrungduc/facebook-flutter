import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlideRightToLeftRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightToLeftRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: Duration(milliseconds: 650),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
        );
}

class SlideBottomToTopRoute extends PageRouteBuilder {
  final Widget page;
  SlideBottomToTopRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: Duration(milliseconds: 700),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
            child: child,
          ),
        );
}

class EnterExitRoute extends PageRouteBuilder {
  final Widget nextPage;
  final Widget prevPage;
  EnterExitRoute({this.prevPage, this.nextPage})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              nextPage,
          transitionDuration: Duration(milliseconds: 1000),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: <Widget>[
              SlideTransition(
                position: new Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-0.1, 0.0),
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                child: prevPage,
              ),
              SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(0.2, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                child: nextPage,
              )
            ],
          ),
        );
}
