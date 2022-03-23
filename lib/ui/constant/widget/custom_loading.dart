import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoading extends StatelessWidget {
  final double size;

  const CustomLoading({Key? key, this.size = 8}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Lottie.asset(
      "${AssetPath.jsonPath}loading.json",
      width: size * 16 * SizeConfig.scaleDiagonal,
      height: size * 9 * SizeConfig.scaleDiagonal,
    );
  }
}
