import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';

class CustomThumbImage extends StatelessWidget {
  final Function? onTap;
  final String? imageUrl;
  final String? postId;
  final BoxFit boxFit;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const CustomThumbImage({
    Key? key,
    this.onTap,
    this.postId,
    required this.imageUrl,
    this.boxFit = BoxFit.contain,
    this.memCacheWidth = 100,
    this.memCacheHeight = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: CustomBaseCacheImage(
        imageUrl: "$imageUrl",
        memCacheHeight: memCacheHeight,
        memCacheWidth: memCacheWidth,
        widthPlaceHolder: 100,
        heightPlaceHolder: 100,
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: boxFit,
                image: imageProvider,
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage('${AssetPath.pngPath}content-error.png'),
            ),
          ),
        ),
        emptyWidget: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              image: AssetImage('${AssetPath.pngPath}content-error.png'),
            ),
          ),
        ),
      ),
    );
  }
}
