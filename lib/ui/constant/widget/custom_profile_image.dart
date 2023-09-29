import 'custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';

class CustomProfileImage extends StatelessWidget {
  final double width;
  final double height;
  final Function? onTap;
  final bool following;
  final String? imageUrl;
  final UserBadgeModel? badge;
  final bool allwaysUseBadgePadding;
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
    this.badge,
    this.cacheKey,
    this.following = false,
    this.forStory = false,
    this.allwaysUseBadgePadding = false, // add padding to make image size consistent when there is no badge
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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(
                  badge != null || allwaysUseBadgePadding ? (width * 0.08) : 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(forStory ? (width * 0.25) : 50),
                  child: cacheKey != null
                      ? Image.network(
                          '$imageUrl',
                          width: width,
                          height: height,
                          key: cacheKey != null ? ValueKey(cacheKey) : null,
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
                          },
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          '$imageUrl',
                          width: width,
                          height: height,
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return Image.asset('${AssetPath.pngPath}profile-error.jpg', fit: BoxFit.fitWidth);
                          },
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Image.network(
                forStory ? '${badge?.badgeProfile}' : '${badge?.badgeOther}',
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Container();
                },
              ),
            ],
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
      //         image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
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
      //         image: AssetImage('${AssetPath.pngPath}profile-error.jpg'),
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
