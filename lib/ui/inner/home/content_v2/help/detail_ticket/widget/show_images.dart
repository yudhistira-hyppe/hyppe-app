import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';

class ShowImages extends StatefulWidget {
  List<String> imageUrls;
  ShowImages({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<ShowImages> createState() => _ShowImagesState();
}

class _ShowImagesState extends State<ShowImages> {
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
            width: context.getWidth() * 0.8,
            child: PageView.builder(
              controller:  _pageController,
                onPageChanged: (idx){
                  setState(() {
                    index = idx;
                  });
                },
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return CustomCacheImage(
                    imageUrl: widget.imageUrls[index],
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
                    ),);
                }),
          ),
        ),
        if(index != 0)
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: (){
              _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
            },
            child: const CustomIconWidget(
              width: 100,
              height: 100,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              defaultColor: false,
              color: kHyppePrimary,
            ),
          ),
        ),
        if(index != (widget.imageUrls.length - 1))
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: (){
              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
            },
            child: const CustomIconWidget(
              width: 100,
              height: 100,
              iconData: "${AssetPath.vectorPath}arrow_right.svg",
              defaultColor: false,
              color: kHyppePrimary,
            ),
          ),
        )
      ],
    );
  }
}

