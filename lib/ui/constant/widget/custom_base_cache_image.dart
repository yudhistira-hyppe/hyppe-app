import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class CustomCacheManager {
  static const key = customCacheKey;
  static CacheManager instance = CacheManager(Config(key, stalePeriod: const Duration(seconds: 1)));
}

class CustomBaseCacheImage extends StatelessWidget {
  final String? imageUrl;
  final String? cacheKey;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final double widthPlaceHolder;
  final double heightPlaceHolder;
  final Widget? placeHolderWidget;
  final Widget emptyWidget;
  final Map<String, String>? headers;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;
  final Widget Function(BuildContext context, ImageProvider imageProvider)? imageBuilder;

  const CustomBaseCacheImage({
    Key? key,
    this.headers,
    this.cacheKey,
    this.imageUrl,
    this.errorWidget,
    this.imageBuilder,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeHolderWidget,
    required this.emptyWidget,
    this.widthPlaceHolder = 35,
    this.heightPlaceHolder = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // System().checkMemory();
    SizeConfig().init(context);
    return (imageUrl ?? '').isNotEmpty
        ? CachedNetworkImage(
            cacheKey: cacheKey, // "$imageUrl${DateTime.now().minute}",
            imageUrl: "$imageUrl",
            httpHeaders: headers,
            errorWidget: errorWidget,
            imageBuilder: imageBuilder,
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            filterQuality: FilterQuality.none,
            // cacheManager: CustomCacheManager.instance,
            placeholder: (context, url) =>
                placeHolderWidget ??
                UnconstrainedBox(
                  child: Container(
                    alignment: Alignment.center,
                    child: const CustomLoading(),
                    width: widthPlaceHolder * SizeConfig.scaleDiagonal,
                    height: heightPlaceHolder * SizeConfig.scaleDiagonal,
                  ),
                ),
          )
        : emptyWidget;
    // return (imageUrl ?? '').isNotEmpty
    //     ? OptimizedCacheImage(
    //         imageUrl: "$imageUrl",
    //         memCacheHeight: memCacheHeight,
    //         memCacheWidth: memCacheWidth,
    //         imageBuilder: imageBuilder,
    //         // maxHeightDiskCache: 500,
    //         // maxWidthDiskCache: 500,
    //         errorWidget: errorWidget,
    //         placeholder: (context, url) =>
    //             placeHolderWidget ??
    //             UnconstrainedBox(
    //               child: Container(
    //                 alignment: Alignment.center,
    //                 width: widthPlaceHolder * SizeConfig.scaleDiagonal,
    //                 height: heightPlaceHolder * SizeConfig.scaleDiagonal,
    //                 child: const CustomLoading(),
    //               ),
    //             ),
    //       )
    //     : emptyWidget;
  }
}
