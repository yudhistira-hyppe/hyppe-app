import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';

class CustomThumbImage extends StatelessWidget {
  final Function? onTap;
  final String? imageUrl;
  final String? postId;
  final BoxFit boxFit;

  const CustomThumbImage({
    Key? key,
    this.onTap,
    this.postId,
    required this.imageUrl,
    this.boxFit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: CustomBaseCacheImage(
        imageUrl: "$imageUrl",
        memCacheHeight: 100,
        memCacheWidth: 100,
        widthPlaceHolder: 100,
        heightPlaceHolder: 100,
        imageBuilder: (context, imageProvider) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: boxFit,
                  image: imageProvider,
                ),
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('${AssetPath.pngPath}content-error.png'),
              ),
            ),
          ),
        ),
        emptyWidget: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('${AssetPath.pngPath}content-error.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
