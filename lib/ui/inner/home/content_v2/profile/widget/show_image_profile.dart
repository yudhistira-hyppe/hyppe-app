import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../constant/widget/custom_icon_widget.dart';

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
        // Positioned.fill(child: Container(
        //   decoration: BoxDecoration(color: context.getColorScheme().secondary.withOpacity(0.5)),
        // )),
        Positioned(
          top: 150,
          right: 20,
          child: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: const CustomIconWidget(
              width: 50,
              height: 50,
              iconData: "${AssetPath.vectorPath}close.svg",
              defaultColor: false,
              color: kHyppePrimary,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            color: Colors.transparent,
            width: context.getWidth(),
            child: CustomCacheImage(
              imageUrl: widget.imageUrl,
              imageBuilder: (_, imageProvider) {
                return Container(
                  height: context.getWidth() * 0.8,
                  width: context.getWidth() * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                  ),
                );
              },
              errorWidget: (_, __, ___) {
                return Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('${AssetPath.pngPath}content-error.png'),
                    ),
                  ),
                );
              },
              emptyWidget: Container(
                height: 50,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('${AssetPath.pngPath}content-error.png'),
                  ),
                ),
              ),),
          ),
        ),
      ],
    );
  }
}

