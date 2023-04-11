import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class TestPageImage extends StatefulWidget {
  const TestPageImage({super.key});

  @override
  State<TestPageImage> createState() => _TestPageImageState();
}

class _TestPageImageState extends State<TestPageImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 300,
        height: 300,
        color: Colors.transparent,
        child: PinchZoom(
          onZoomStart: () {},
          onZoomEnd: () {},
          child: CustomBaseCacheImage(
            memCacheWidth: 100,
            memCacheHeight: 100,
            widthPlaceHolder: 80,
            heightPlaceHolder: 80,
            imageUrl: 'https://i2.wp.com/blog.tripcetera.com/id/wp-content/uploads/2020/10/Danau-Toba-edited.jpg',
            imageBuilder: (context, imageProvider) => ClipRRect(
              borderRadius: BorderRadius.circular(20), // Image border
              child: Image(
                image: imageProvider,
              ),
            ),
            emptyWidget: Container(
              // const EdgeInsets.symmetric(horizontal: 4.5),

              // height: 500,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
