import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class AllSearchShimmer extends StatelessWidget {
  const AllSearchShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AllSearchShimmer');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleShimmer(context),
            userShimmer(context),
            userShimmer(context),
            userShimmer(context),
            userShimmer(context),
            userShimmer(context),
            userShimmer(context),
            userShimmer(context),
          ],
        ),
      ),
    );
  }

  Widget titleShimmer(context) {
    return const CustomShimmer(
      width: 120,
      height: 15,
    );
  }

  Widget userShimmer(context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const CustomShimmer(
            width: 70,
            height: 70,
            radius: 50,
          ),
          sixPx,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomShimmer(
                width: 150,
                height: 20,
              ),
              sixPx,
              CustomShimmer(
                width: 220,
                height: 20,
              ),
            ],
          )
        ],
      ),
    );
  }
}
