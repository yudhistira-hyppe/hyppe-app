import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget child;
  final double? width;
  final double height;
  final Function? function;
  final ButtonStyle? buttonStyle;

  const CustomElevatedButton({
    required this.child,
    required this.width,
    required this.height,
    required this.function,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
        child: ElevatedButton(
          child: child,
          style: buttonStyle,
          onPressed: function as void Function()?,
        ),
      ),
    );
  }
}
