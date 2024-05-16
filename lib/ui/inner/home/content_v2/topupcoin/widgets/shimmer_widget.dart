import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ContentLoader extends StatelessWidget {
  const ContentLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.black45,
      highlightColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.8,
          height: MediaQuery.of(context).size.width / 5,
          decoration: BoxDecoration(
            color: Colors.black12,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(12.0)
          ),
      ),
    );
  }
}
