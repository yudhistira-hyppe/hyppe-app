import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
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
    // if ((imageUrl ?? '').isNotEmpty || (imageUrl ?? '').isUrlLink()) {
    //   return CachedNetworkImage(
    //     cacheKey: cacheKey, // "$imageUrl${DateTime.now().minute}",
    //     imageUrl: "$imageUrl",
    //     httpHeaders: headers,
    //     errorWidget: errorWidget,
    //     imageBuilder: imageBuilder,
    //     memCacheWidth: memCacheWidth,
    //     memCacheHeight: memCacheHeight,
    //     // maxHeightDiskCache: 600,
    //     // maxWidthDiskCache: 600,
    //     // filterQuality: FilterQuality.none,
    //     // cacheManager: CacheManager(Config(
    //     //   'keyImage',
    //     //   stalePeriod: const Duration(days: 7),
    //     //   //one week cache period
    //     // )),
    //     placeholder: (context, url) =>
    //         placeHolderWidget ??
    //         UnconstrainedBox(
    //           child: Container(
    //             alignment: Alignment.center,
    //             child: const CustomLoading(),
    //             width: widthPlaceHolder * SizeConfig.scaleDiagonal,
    //             height: heightPlaceHolder * SizeConfig.scaleDiagonal,
    //           ),
    //         ),
    //   );
    // } else {
    //   return emptyWidget;
    // }

    if ((imageUrl ?? '').isNotEmpty || (imageUrl ?? '').isUrlLink()) {
      return (imageUrl ?? '').isNotEmpty
          ? OptimizedCacheImage(
              imageUrl: imageUrl ?? '',
              memCacheHeight: 60,
              memCacheWidth: 45,
              imageBuilder: imageBuilder,

              // filterQuality: FilterQuality.none,
              // cacheManager: CacheManager(Config(
              //   'keyImage',
              //   stalePeriod: const Duration(days: 7),
              //   //one week cache period
              // )),
              // maxHeightDiskCache: 500,
              // maxWidthDiskCache: 500,
              errorWidget: errorWidget,
              placeholder: (context, url) =>
                  placeHolderWidget ??
                  UnconstrainedBox(
                    child: Container(
                      alignment: Alignment.center,
                      width: widthPlaceHolder * SizeConfig.scaleDiagonal,
                      height: heightPlaceHolder * SizeConfig.scaleDiagonal,
                      child: const CustomLoading(),
                    ),
                  ),
            )
          : emptyWidget;
    } else {
      return emptyWidget;
    }
  }
}
