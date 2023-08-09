import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';

class SearchShimmer extends StatelessWidget {
  const SearchShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SearchShimmer');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CustomShimmer(width: double.infinity, height: 100, radius: 16, margin: EdgeInsets.symmetric(vertical: 8),),
            CustomShimmer(width: double.infinity, height: 100, radius: 16, margin: EdgeInsets.symmetric(vertical: 8),),
            CustomShimmer(width: double.infinity, height: 100, radius: 16, margin: EdgeInsets.symmetric(vertical: 8),),
            CustomShimmer(width: double.infinity, height: 100, radius: 16, margin: EdgeInsets.symmetric(vertical: 8),),
            CustomShimmer(width: double.infinity, height: 100, radius: 16, margin: EdgeInsets.symmetric(vertical: 8),),
            CustomShimmer(width: double.infinity, height: 100, radius: 16, margin: EdgeInsets.symmetric(vertical: 8),),
          ],
        ),
      ),
    );
  }
}
