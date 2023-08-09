import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomConvetti extends StatelessWidget {
  final double size;

  const CustomConvetti({Key? key, this.size = 8}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Lottie.asset(
      "${AssetPath.jsonPath}convetti-2.json",
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
    );
  }
}
