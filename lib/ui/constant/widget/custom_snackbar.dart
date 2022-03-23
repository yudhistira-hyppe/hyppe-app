import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget {
  final double height;
  final Color color;
  final Widget child;
  const CustomSnackBar({
    Key? key,
    this.height = 56,
    required this.child,
    this.color = kHyppeTextSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      content: SafeArea(
        child: SizedBox(
          height: height,
          child: child,
        ),
      ),
      backgroundColor: color,
      duration: const Duration(days: 1),
    );
  }
}
