import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_shimmer.dart';

class GridContentsShimmer extends StatelessWidget {
  const GridContentsShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            sixteenPx,
            Expanded(child: CustomShimmer(width: double.infinity, height: 50, radius: 25,)),
            twelvePx,
            Expanded(child: CustomShimmer(width: double.infinity, height: 50, radius: 25,)),
            twelvePx,
            Expanded(child: CustomShimmer(width: double.infinity, height: 50, radius: 25,)),
            sixteenPx
          ],
        ),
        sixteenPx,
        SearchShimmer()

      ],
    );
  }
}
