import 'package:flutter/material.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final Curve curve;
  final Duration duration;
  final Offset begin;
  final Offset end;
  final Object? arguments; // Thêm tham số arguments

  CustomPageRoute({
    required this.page,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 500),
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
    this.arguments, // Truyền arguments khi khởi tạo
  }) 
  : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    settings: RouteSettings(arguments: arguments), // Gán arguments vào RouteSettings
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var forwardAnimation = Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      var reverseAnimation = Tween<Offset>(
        begin: Offset(-1, 0),
        end: end,
      ).animate(CurvedAnimation(parent: animation, curve: curve));

      return SlideTransition(
        position: animation.status == AnimationStatus.reverse
            ? reverseAnimation
            : forwardAnimation,
        child: child,
      );
    },
    transitionDuration: duration,
    reverseTransitionDuration: duration,
  );
}
