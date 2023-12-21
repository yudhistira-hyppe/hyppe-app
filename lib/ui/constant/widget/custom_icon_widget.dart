import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconWidget extends StatelessWidget {
  final Color? color;
  final String iconData;
  final double? width;
  final double? height;
  final bool defaultColor;
  const CustomIconWidget({
    Key? key,
    required this.iconData,
    this.color,
    this.width,
    this.height,
    this.defaultColor = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: SvgPicture.asset(
        iconData,
        width: width,
        height: height,
        color: defaultColor ? Theme.of(context).iconTheme.color : color,
        allowDrawingOutsideViewBox: true,
      ),
    );
  }
}
