import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:flutter/material.dart';

class SearchShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SearchShimmer');
    return GridView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 18,
      itemBuilder: (BuildContext context, int index) => Container(
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              const CustomShimmer(
                width: double.infinity,
                height: double.infinity,
                radius: 8,
              ),
              Align(
                alignment: const Alignment(-0.85, 0.85),
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(5 * SizeConfig.scaleDiagonal),
                    child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}like.svg"),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
