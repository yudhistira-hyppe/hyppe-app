import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';

class ShimmerBadge extends StatelessWidget {
  const ShimmerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    isFromSplash = false;
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset("${AssetPath.pngPath}badge_banner_background.png"),
              Positioned.fill(
                  child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CustomShimmer(width: 80, height: 80, radius: 100),
                    sixteenPx,
                    CustomShimmer(width: 180, height: 30, radius: 38),
                  ],
                ),
              ))
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomShimmer(width: 180, height: 20, radius: 8),
                twentyFourPx,
                GridView.builder(
                  itemCount: 20,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 109 / 140,
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFEAEAEA)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Stack(
                              fit: StackFit.passthrough,
                              children: [
                                Container(
                                  // padding: const EdgeInsets.only(top: 5.0, left: 6, right: 6, bottom: 2),
                                  margin: const EdgeInsets.only(top: 2.0, left: 6, right: 6, bottom: 2),
                                  child: const ClipOval(
                                    child: CustomShimmer(width: 43, height: 43, radius: 100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xFFEAEAEA), thickness: 1),
                          sixPx,
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0),
                            child: CustomShimmer(width: 70, height: 10, radius: 5),
                          ),
                          sixPx,
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFE8E8E8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                CustomShimmer(width: 80, height: 10, radius: 5),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
