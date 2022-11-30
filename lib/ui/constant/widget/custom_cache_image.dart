import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/asset_path.dart';
import 'custom_base_cache_image.dart';

class CustomCacheImage extends StatelessWidget {
  final String? imageUrl;
  final Widget Function(BuildContext context, ImageProvider imageProvider)? imageBuilder;
  final Widget Function(BuildContext context, String url, dynamic error)? errorWidget;
  final Widget emptyWidget;

  const CustomCacheImage({Key? key, this.imageUrl, this.imageBuilder, this.errorWidget, required this.emptyWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if((imageUrl ?? '').isEmpty){
      return emptyWidget;
    }else{
      return  CachedNetworkImage(
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
  Widget _octoErrorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
      ) {
    return errorWidget!(context, imageUrl ?? '', error);
  }
}


