import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';

class ShimmerDetailTransactionHistory extends StatelessWidget {
  const ShimmerDetailTransactionHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ShimmerDetailTransactionHistory');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CustomShimmer(width: (SizeConfig.screenWidth! / 4), height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
            child: CustomShimmer(width: SizeConfig.screenWidth!, height: 20, radius: 4),
          ),
        ],
      ),
    );
  }
}
