import 'dart:ui';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:flutter/material.dart';

class CustomBackgroundLayer extends StatelessWidget {
  final double sigmaX;
  final double sigmaY;
  final String? thumbnail;
  const CustomBackgroundLayer({Key? key, this.thumbnail, this.sigmaX = 5, this.sigmaY = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomBaseCacheImage(
            imageUrl: "$thumbnail",
            placeHolderWidget: const Center(child: CustomLoading()),
            imageBuilder: (context, imageProvider) =>
                Container(decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: imageProvider))),
            errorWidget: (context, url, error) => Container(color: Colors.black)),
        BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
            child: Container(color: Colors.black.withOpacity(0)))
      ],
    );
  }
}
