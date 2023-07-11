import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/widget/shimmer_referral.dart';

class ShimmerListLeaderboard extends StatelessWidget {
  const ShimmerListLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 11,
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
            ));
  }
}
