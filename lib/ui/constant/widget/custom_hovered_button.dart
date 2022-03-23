import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';

class CustomHoveredButton extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Function function;

  const CustomHoveredButton({required this.child, required this.width, required this.height, required this.function});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
        child: ElevatedButton(
            child: child,
            onPressed: function as void Function()?,
            style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(const BorderSide(color: kHyppePrimary)),
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(183, 15, 144, 0.05)))));
  }
}
