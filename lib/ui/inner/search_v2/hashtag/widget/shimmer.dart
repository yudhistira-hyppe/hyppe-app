import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/themes/hyppe_colors.dart';
class HashtagShimmer extends StatelessWidget {
  const HashtagShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              decoration: const BoxDecoration(
                gradient: kSkeleton,
                borderRadius: BorderRadius.all(Radius.circular(25))
              ),
            ),
            Column(
              children: [
                Container(
                  height: 15,
                  width: 0.7 * context.getWidth(),
                  decoration: const BoxDecoration(
                      gradient: kSkeleton,
                      borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                ),
                Container(
                  height: 15,
                  width: 0.5 * context.getWidth(),
                  decoration: const BoxDecoration(
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
