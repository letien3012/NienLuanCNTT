import 'package:flutter/material.dart';

class ImageHelper {
  static Widget loadFromAsset(
    String imagePath,{
    double? width,
    double? height,
    BorderRadius? radius,
    BoxFit? fit,
    Color? color,
    Alignment? alignment,
    }
  ){
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        color: color,
        alignment: alignment ?? Alignment.center,
      ),
    );
  }
}