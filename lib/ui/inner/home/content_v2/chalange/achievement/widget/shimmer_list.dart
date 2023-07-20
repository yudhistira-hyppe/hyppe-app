import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ShimmerListAchievement extends StatelessWidget {
  const ShimmerListAchievement({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: CustomShimmer(width: SizeConfig.screenWidth, height: 50, radius: 8),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: 11,
              itemBuilder: (context, index) => Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Row(
                          children: [
                            const ClipOval(child: CustomShimmer(width: 43, height: 41, radius: 50)),
                            twelvePx,
                            Expanded(
                              child: Column(
                                children: [
                                  CustomShimmer(width: (SizeConfig.screenWidth ?? 0) * 0.8, height: 11, radius: 50),
                                  sixPx,
                                  CustomShimmer(width: (SizeConfig.screenWidth ?? 0) * 0.8, height: 11, radius: 50),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
        ],
      ),
    );
  }
}
