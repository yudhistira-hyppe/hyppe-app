import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import '../../../app.dart';
import 'custom_base_cache_image.dart';
import 'custom_icon_widget.dart';
import 'custom_loading.dart';
import 'custom_spacer.dart';
import 'custom_text_widget.dart';

class CustomContentModeratedWidget extends StatelessWidget {
  final bool isSafe;
  final bool isSale;
  final double? width;
  final double? height;
  final ImageContent thumbnail;
  final BoxFit boxFitError;
  final BoxFit boxFitContent;
  final double blurIfNotSafe;
  final FeatureType featureType;
  final EdgeInsetsGeometry padding;
  final Widget? placeHolder;
  final int? memCacheWidth;
  final int? memCacheHeight;

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
      this.featureType = FeatureType.pic,
      this.memCacheWidth,
      this.memCacheHeight,
      this.placeHolder})
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
              (thumbnail is ImageUrl)
                  ? CustomBaseCacheImage(
                      cacheKey: thumbnail.id,
                      imageUrl: (thumbnail as ImageUrl).url,
                      memCacheWidth: memCacheWidth ?? 70,
                      memCacheHeight: memCacheHeight ?? 70,
                      imageBuilder: (_, imageProvider) {
                        return Container(
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: imageProvider,
                            ),
                          ),
                        );
                      },
                      placeHolderWidget: placeHolder ?? ClipRRect(borderRadius: BorderRadius.circular(10), child: const CustomShimmer()),
                      errorWidget: (_, url, error) {
                        print('image url is $url $error $connectInternet');
                        if (connectInternet) {
                          return ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              child: Image.network(
                                url,
                                fit: boxFitContent,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) {
                                  return ClipRRect(borderRadius: BorderRadius.circular(10), child: const CustomShimmer());
                                },
                                loadingBuilder: (_, child, event) {
                                  if (event == null) {
                                    return Center(child: child);
                                  } else {
                                    return ClipRRect(borderRadius: BorderRadius.circular(10), child: const CustomShimmer());
                                  }
                                },
                              ));
                        }
                        return ClipRRect(borderRadius: BorderRadius.circular(10), child: const CustomShimmer());
                      },
                      emptyWidget: ClipRRect(borderRadius: BorderRadius.circular(10), child: const CustomShimmer()),
                    )
                  : ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Image.memory(
                        (thumbnail as ImageBlob).data,
                        fit: boxFitContent,
                        width: width,
                        height: height,
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
                    height: 22,
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

class ImageUrl extends ImageContent {
  String url;
  ImageUrl(super.id, {required this.url});
}

class ImageBlob extends ImageContent {
  Uint8List data;
  ImageBlob(super.id, {required this.data});
}

class ImageContent {
  String? id;
  ImageContent(this.id);
}
