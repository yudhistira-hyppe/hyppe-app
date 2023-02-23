import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'custom_loading.dart';

class CustomImageAssets extends StatelessWidget {
  double? width;
  double? height;
  String assetPath;
  BorderRadius? borderRadius;
  CustomImageAssets({Key? key, required this.assetPath, this.width, this.height, this.borderRadius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(width != null && height != null){
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage(assetPath),
          ),
        ),
      );
    }else{
      final image = Image.asset(assetPath);
      final completer = Completer<ui.Image>();
      image.image
          .resolve(const ImageConfiguration()).addListener(ImageStreamListener((image, synchronousCall) {
        completer.complete(image.image);
      }));
      return FutureBuilder(
        future: completer.future,
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return Container(
                width: snapshot.data?.width.toDouble(),
                height: snapshot.data?.height.toDouble(),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage(assetPath),
                  ),
                ),
              );
            }else{
              return const CustomLoading();
            }
          }
      );
    }
    }

}
