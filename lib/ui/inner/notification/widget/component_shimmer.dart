import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';

class ComponentShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomShimmer(radius: 100, width: 50 * SizeConfig.scaleDiagonal, height: 50 * SizeConfig.scaleDiagonal),
          sixteenPx,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomShimmer(radius: 4, height: 16, width: SizeConfig.screenWidth! / 3),
              sixPx,
              CustomShimmer(radius: 4, height: 16, width: SizeConfig.screenWidth! / 2),
            ],
          ),
        ],
      ),
    );
  }
}
