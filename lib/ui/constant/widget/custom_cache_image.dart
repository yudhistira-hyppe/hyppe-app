import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'custom_base_cache_image.dart';

class CustomCacheImage extends StatelessWidget {
  final String? imageUrl;
  final Widget Function(BuildContext context, ImageProvider imageProvider)? imageBuilder;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;

  const CustomCacheImage({Key? key, this.imageUrl, this.imageBuilder, this.errorWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      errorWidget: errorWidget,
      imageBuilder: imageBuilder,
      filterQuality: FilterQuality.none,
      cacheManager: CustomCacheManager.instance,
      placeholder: (context, url) => UnconstrainedBox(
        child: SizedBox(
          height: 35 * SizeConfig.scaleDiagonal,
          width: 35 * SizeConfig.scaleDiagonal,
          child: const CustomLoading(),
        ),
      ),
    );
  }
}
