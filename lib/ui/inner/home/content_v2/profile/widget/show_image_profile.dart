import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ux/routing.dart';

import '../../../../../../../core/constants/asset_path.dart';

class ShowImageProfile extends StatefulWidget {
  String imageUrl;
  ShowImageProfile({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<ShowImageProfile> createState() => _ShowImageProfileState();
}

class _ShowImageProfileState extends State<ShowImageProfile> {
  var index = 0;
  late PageController _pageController;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ShowImages');
    _pageController = PageController(initialPage: index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => Routing().moveBack(),
          child: Stack(
            children: [
              Image.asset(
                // '${AssetPath.pngPath}abstrak.jpg',
                '${AssetPath.pngPath}abstract.png',
                height: SizeConfig.screenHeight,
                fit: BoxFit.fitHeight,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
            ],
          ),
        ),
        // Positioned.fill(child: Container(
        //   decoration: BoxDecoration(color: context.getColorScheme().secondary.withOpacity(0.5)),
        // )),
        // Positioned(
        //   top: 150,
        //   right: 20,
        //   child: GestureDetector(
        //     onTap: () {
        //       Navigator.pop(context);
        //     },
        //     child: const CustomIconWidget(
        //       width: 50,
        //       height: 50,
        //       iconData: "${AssetPath.vectorPath}close.svg",
        //       defaultColor: false,
        //       color: kHyppePrimary,
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.center,
          child: Center(
            child: CustomCacheImage(
              imageUrl: widget.imageUrl,
              imageBuilder: (_, imageProvider) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.fitHeight,
                    width: context.getWidth() * 0.8,
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth),
                );
              },
              emptyWidget: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
