import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/themes/hyppe_colors.dart';
class HashtagShimmer extends StatelessWidget {
  const HashtagShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HashtagShimmer');
    return Shimmer.fromColors(
      highlightColor: kSkeletonHighlightColor,
      baseColor: kSkeletonBaseColor,
      child: Container(
        margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: kSkeleton,
                borderRadius: BorderRadius.all(Radius.circular(25))
              ),
            ),
            eightPx,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 15,
                  width: 0.7 * context.getWidth(),
                  decoration: BoxDecoration(
                      gradient: kSkeleton,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),
                eightPx,
                Container(
                  height: 15,
                  width: 0.5 * context.getWidth(),
                  decoration: BoxDecoration(
                      gradient: kSkeleton,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
