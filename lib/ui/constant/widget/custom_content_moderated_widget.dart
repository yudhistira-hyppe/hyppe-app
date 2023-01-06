import 'dart:ui';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'custom_base_cache_image.dart';
import 'custom_icon_widget.dart';
import 'custom_spacer.dart';
import 'custom_text_widget.dart';

class CustomContentModeratedWidget extends StatelessWidget {
  final bool isSafe;
  final bool isSale;
  final double? width;
  final double? height;
  final String thumbnail;
  final BoxFit boxFitError;
  final BoxFit boxFitContent;
  final double blurIfNotSafe;
  final FeatureType featureType;
  final EdgeInsetsGeometry padding;

  const CustomContentModeratedWidget(
      {Key? key,
      this.width,
      this.height,
      required this.isSafe,
      this.isSale = false,
      this.blurIfNotSafe = 5,
      required this.thumbnail,
      this.padding = EdgeInsets.zero,
      this.boxFitError = BoxFit.fill,
      this.boxFitContent = BoxFit.cover,
      this.featureType = FeatureType.pic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final theme = Theme.of(context);
    ValueNotifier<int> _networklHasErrorNotifier = ValueNotifier(0);

    return ValueListenableBuilder(
      valueListenable: _networklHasErrorNotifier,
      builder: (context, count, child) {
        return Padding(
          padding: padding,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomBaseCacheImage(
                // cacheKey: _networklHasErrorNotifier.value.toString(),
                imageUrl: thumbnail,
                memCacheWidth: 50,
                memCacheHeight: 50,
                imageBuilder: (_, imageProvider) {
                  return Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        fit: boxFitContent,
                        image: imageProvider,
                      ),
                    ),
                  );
                },
                errorWidget: (_, __, ___) {
                  return GestureDetector(
                    onTap: () {
                      _networklHasErrorNotifier.value++;
                    },
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: boxFitError,
                          image: const AssetImage('${AssetPath.pngPath}content-error.png'),
                        ),
                      ),
                    ),
                  );
                },
                emptyWidget: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: boxFitError,
                      image: const AssetImage('${AssetPath.pngPath}content-error.png'),
                    ),
                  ),
                ),
              ),
              if (featureType != FeatureType.pic)
                CustomIconWidget(
                  defaultColor: false,
                  width: 24 * SizeConfig.scaleDiagonal,
                  height: 24 * SizeConfig.scaleDiagonal,
                  iconData: "${AssetPath.vectorPath}pause.svg",
                ),
              if (!isSafe)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurIfNotSafe,
                      sigmaY: blurIfNotSafe,
                    ),
                    child: Container(
                      width: width,
                      height: height,
                      color: Colors.black.withOpacity(0),
                    ),
                  ),
                ),
              if (!isSafe)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomIconWidget(
                        defaultColor: false,
                        iconData: "${AssetPath.vectorPath}moderated.svg",
                      ),
                      eightPx,
                      CustomTextWidget(
                        textToDisplay: "in Moderate",
                        textStyle: theme.textTheme.bodyText2,
                      )
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.topRight,
                child: Visibility(
                  visible: isSale,
                  child: const CustomIconWidget(
                    iconData: "${AssetPath.vectorPath}sale.svg",
                    defaultColor: false,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
