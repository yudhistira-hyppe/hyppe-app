import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:shimmer/shimmer.dart';

class ContentLoader extends StatelessWidget {
  const ContentLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 52,
            width: SizeConfig.screenWidth! * .4,
            child: Shimmer.fromColors(
              baseColor: Colors.black45,
              highlightColor: Colors.white,
              child: Container(
                height: 24,
                width: SizeConfig.screenWidth! * .7,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Shimmer.fromColors(
            baseColor: Colors.black45,
            highlightColor: Colors.white,
            child: Container(
              height: 169,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8)
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Shimmer.fromColors(
            baseColor: Colors.black45,
            highlightColor: Colors.white,
            child: Container(
              height: 169,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8)
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Shimmer.fromColors(
            baseColor: Colors.black45,
            highlightColor: Colors.white,
            child: Container(
              height: 169,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.black12,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
