import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';

class BothProfileTopShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BothProfileTopShimmer');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomShimmer(
                width: 80 * SizeConfig.scaleDiagonal,
                height: 80 * SizeConfig.scaleDiagonal,
                boxShape: BoxShape.circle,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Column(
                      children: [
                        CustomShimmer(height: 12, width: (SizeConfig.screenWidth! * 0.1), radius: 4),
                        eightPx,
                        CustomShimmer(height: 12, width: (SizeConfig.screenWidth! * 0.15), radius: 4),
                      ],
                    ),
                    SizedBox(width: 39 * SizeConfig.scaleDiagonal),
                    Column(
                      children: [
                        CustomShimmer(height: 12, width: (SizeConfig.screenWidth! * 0.1), radius: 4),
                        eightPx,
                        CustomShimmer(height: 12, width: (SizeConfig.screenWidth! * 0.15), radius: 4),
                      ],
                    ),
                    SizedBox(width: 39 * SizeConfig.scaleDiagonal),
                    Column(
                      children: [
                        CustomShimmer(height: 12, width: (SizeConfig.screenWidth! * 0.1), radius: 4),
                        eightPx,
                        CustomShimmer(height: 12, width: (SizeConfig.screenWidth! * 0.15), radius: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 2), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          )
        ],
      ),
    );
  }
}
