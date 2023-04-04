import 'dart:math';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';

import 'custom_icon_widget.dart';
import 'custom_base_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

class CustomProfileImage extends StatelessWidget {
  final double width;
  final double height;
  final Function? onTap;
  final bool following;
  final String? imageUrl;
  final String? cacheKey;
  final Function? onFollow;
  final Map<String, String>? headers;
  final bool forStory;

  const CustomProfileImage({
    Key? key,
    this.onTap,
    this.headers,
    this.onFollow,
    required this.width,
    required this.height,
    required this.imageUrl,
    this.cacheKey,
    this.following = false,
    this.forStory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(forStory ? 20 : 50),
            child: Image.network(
              '$imageUrl',
              key: ValueKey(cacheKey),
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Image.asset('${AssetPath.pngPath}profile-error.png', fit: BoxFit.fitWidth);
              },
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),

      // child: CustomBaseCacheImage(
      //   cacheKey: ValueKey(Random().nextInt(100)).toString(),
      //   imageUrl: imageUrl,
      //   headers: headers,
      //   imageBuilder: (context, imageProvider) => Container(
      //     width: width,
      //     height: height,
      //     alignment: Alignment.bottomCenter,
      //     decoration: forStory
      //         ? BoxDecoration(
      //             // shape: BoxShape.circle,
      //             borderRadius: BorderRadius.circular(20),
      //             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      //           )
      //         : BoxDecoration(
      //             shape: BoxShape.circle,
      //             image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      //           ),
      //     child: _buildBody(),
      //   ),
      //   errorWidget: (context, url, error) => Container(
      //     width: width,
      //     height: height,
      //     alignment: Alignment.bottomCenter,
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(20),
      //       image: const DecorationImage(
      //         fit: BoxFit.contain,
      //         image: AssetImage('${AssetPath.pngPath}profile-error.png'),
      //       ),
      //       // shape: BoxShape.circle,
      //     ),
      //     child: _buildBody(),
      //   ),
      //   emptyWidget: Container(
      //     width: width,
      //     height: height,
      //     alignment: Alignment.bottomCenter,
      //     decoration: BoxDecoration(
      //       borderRadius: BorderRadius.circular(20),
      //       image: DecorationImage(
      //         fit: BoxFit.contain,
      //         image: AssetImage('${AssetPath.pngPath}profile-error.png'),
      //       ),
      //       // shape: BoxShape.circle,
      //     ),
      //     child: _buildBody(),
      //   ),
      // ),
    );
  }

  Widget _buildBody() {
    if (!following) {
      return Transform.translate(
        offset: const Offset(0.0, 7.0),
        child: GestureDetector(
          onTap: onFollow as void Function()?,
          child: const CustomIconWidget(
            defaultColor: false,
            iconData: '${AssetPath.vectorPath}follow.svg',
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
