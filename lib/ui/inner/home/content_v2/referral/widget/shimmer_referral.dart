import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ShimmerReferral extends StatelessWidget {
  const ShimmerReferral({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ShimmerReferral');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmer(width: (SizeConfig.screenWidth! * 0.3), height: 20, radius: 4),
          twelvePx,
          CustomShimmer(width: (SizeConfig.screenWidth!), height: 50, radius: 4),
          twelvePx,
          twelvePx,
          CustomShimmer(width: (SizeConfig.screenWidth! * 0.3), height: 20, radius: 4),
          twelvePx,
          CustomShimmer(width: (SizeConfig.screenWidth!), height: 50, radius: 4),
          twelvePx,
          twelvePx,
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Container(
                  height: 360,
                  width: 383,
                  decoration: BoxDecoration(color: kHyppeLightSurface, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 80),
                        color: kHyppeLightSurface,
                        height: 180,
                        width: 180,
                        child: const CustomShimmer(width: 180, height: 180, radius: 4),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CustomShimmer(width: 180, height: 20, radius: 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: const [
                      ClipOval(child: CustomShimmer(width: 100, height: 100, radius: 4)),
                      SizedBox(
                        height: 16,
                      ),
                      CustomShimmer(width: 180, height: 20, radius: 4),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
