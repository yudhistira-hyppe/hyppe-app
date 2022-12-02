import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ShimmerMusicItem extends StatelessWidget {
  const ShimmerMusicItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomShimmer(
            width: 50,
            height: 50,
            radius: 25,
          ),
          twelvePx,
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CustomShimmer(
                width: double.infinity,
                height: 14,
                radius: 7,
              ),
              twelvePx,
              CustomShimmer(
                width: double.infinity * 0.8,
                height: 14,
                radius: 7,
              ),
            ],
          ))
        ],
      ),
    );
  }
}
