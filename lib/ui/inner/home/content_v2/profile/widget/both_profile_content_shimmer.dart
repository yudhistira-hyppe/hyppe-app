import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:flutter/material.dart';

class BothProfileContentShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => Padding(
          padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
          child: const CustomShimmer(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        childCount: 12,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    );
  }
}
