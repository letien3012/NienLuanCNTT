import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({Key? key, this.title, this.ontap, this.color}) :super(key: key);
  final Color? color;
  final String? title;
  final Function()? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: color ?? Colors.white
        ),
        child: Text(title ?? '', style: const TextStyle(fontSize: 16.0, color: Colors.white)),
        alignment: Alignment.center,
      ),
    );
  }
}