import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

class CustomGesture extends StatelessWidget {
  final double? height;
  final double? width;
  final Function() onTap;
  final Widget child;
  final EdgeInsetsGeometry margin;
  const CustomGesture(
      {Key? key,
      this.width,
      this.height,
      required this.onTap,
      required this.child,
      required this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: InkWell(
              onTap: onTap,
              splashColor: context.getColorScheme().primary,
              borderRadius: BorderRadius.circular(8),
              child: child),
        ),
      ),
    );
  }
}
