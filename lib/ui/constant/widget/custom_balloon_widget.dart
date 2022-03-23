import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';

class CustomBalloonWidget extends StatelessWidget {
  final Widget child;

  const CustomBalloonWidget({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: 26,
      child: child,
      alignment: Alignment.center,
      width: 49 * SizeConfig.scaleDiagonal,
    );
  }
}
