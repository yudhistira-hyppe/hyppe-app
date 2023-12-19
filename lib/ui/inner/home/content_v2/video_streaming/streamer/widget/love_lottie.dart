import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoveLootie extends StatelessWidget {
  final double size;

  const LoveLootie({Key? key, this.size = 8}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Lottie.asset(
      "${AssetPath.jsonPath}loveicon.json",
      width: SizeConfig.screenWidth! * 0.3,
      height: SizeConfig.screenHeight! * 0.6,

      // repeat: false,
    );
  }
}
