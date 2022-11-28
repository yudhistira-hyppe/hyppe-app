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
  final Function? onFollow;
  final Map<String, String>? headers;

  const CustomProfileImage({
    Key? key,
    this.onTap,
    this.headers,
    this.onFollow,
    required this.width,
    required this.height,
    required this.imageUrl,
    this.following = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: CustomBaseCacheImage(
        imageUrl: imageUrl,
        headers: headers,
        imageBuilder: (context, imageProvider) => Container(
          width: width,
          height: height,
          child: _buildBody(),
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          child: _buildBody(),
          alignment: Alignment.bottomCenter,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('${AssetPath.pngPath}profile-error.png'),
            ),
            shape: BoxShape.circle,
          ),
        ),
        emptyWidget: Container(
          width: width,
          height: height,
          child: _buildBody(),
          alignment: Alignment.bottomCenter,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('${AssetPath.pngPath}profile-error.png'),
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
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
