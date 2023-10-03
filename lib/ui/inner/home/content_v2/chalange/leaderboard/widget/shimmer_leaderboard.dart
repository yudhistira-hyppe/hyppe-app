import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ShimmerLeaderboard extends StatelessWidget {
  const ShimmerLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const CustomShimmer(width: 100, height: 11, radius: 8),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: const CustomShimmer(width: 300, height: 100, radius: 8),
          ),
          sixteenPx,
          ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            itemBuilder: (context, index) => Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      const ClipOval(child: CustomShimmer(width: 24, height: 24, radius: 4)),
                      twelvePx,
                      const ClipOval(child: CustomShimmer(width: 43, height: 41, radius: 50)),
                      twelvePx,
                      Column(
                        children: const [
                          CustomShimmer(width: 200, height: 11, radius: 50),
                          sixPx,
                          CustomShimmer(width: 200, height: 11, radius: 50),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          twentyFourPx,
          Container(
            height: 50,
            width: SizeConfig.screenWidth,
            color: kHyppeLightSurface,
          ),
          twentyFourPx,
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: const CustomShimmer(width: 250, height: 100, radius: 8),
              ),
              Container(
                child: const CustomShimmer(width: 300, height: 100, radius: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
