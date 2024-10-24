import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/user_template.dart';

import 'custom_profile_image.dart';
import 'custom_spacer.dart';
import 'custom_text_widget.dart';
import 'custom_verified_widget.dart';
import 'story_color_validator.dart';

class ProfileLandingPage extends StatelessWidget {
  final bool isDetail;
  final bool show;
  final bool following;
  final String imageUrl;
  final String? username;
  final Color? textColor;
  final bool? isCelebrity;
  final String createdAt;
  final double widthText;
  final double widthCircle;
  final double heightCircle;
  final Widget spaceProfileAndId;
  final bool showNameAndTimeStamp;
  final Function onTapOnProfileImage;
  final Function onFollow;
  final bool haveStory;
  final FeatureType featureType;
  final String? cacheKey;
  final String? location;
  final String? musicName;
  final bool? isIdVerified;
  final UserBadgeModel? badge;

  const ProfileLandingPage({
    Key? key,
    required this.show,
    required this.onTapOnProfileImage,
    required this.imageUrl,
    required this.username,
    required this.isCelebrity,
    required this.createdAt,
    required this.following,
    this.isDetail = false,
    this.widthText = 150,
    this.showNameAndTimeStamp = true,
    this.spaceProfileAndId = eightPx,
    this.widthCircle = SizeWidget.circleDiameterImageProfileInLongVideoView,
    this.heightCircle = SizeWidget.circleDiameterImageProfileInLongVideoView,
    required this.onFollow,
    this.textColor,
    this.cacheKey,
    this.haveStory = false,
    this.musicName,
    this.location,
    this.isIdVerified,
    required this.featureType,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Visibility(
      visible: show,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          StoryColorValidator(
            haveStory: haveStory,
            featureType: featureType,
            child: CustomProfileImage(
              // cacheKey: cacheKey,
              width: widthCircle,
              height: heightCircle,
              onTap: onTapOnProfileImage,
              imageUrl: imageUrl,
              following: following,
              onFollow: onFollow,
              badge: badge,
            ),
          ),
          Visibility(visible: showNameAndTimeStamp, child: spaceProfileAndId),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTapOnProfileImage as void Function()?,
                  child: Row(
                    children: [
                      Expanded(
                        child: UserTemplate(
                          username: username ?? 'No Username',
                          isVerified: isIdVerified ?? false,
                        ),
                        // CustomTextWidget(
                        //   textToDisplay: username ?? '',
                        //   maxLines: 1,
                        //   textStyle: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
                        //   textAlign: TextAlign.left,
                        // ),
                      ),
                      tenPx,
                      CustomVerifiedWidget(verified: isCelebrity),
                    ],
                  ),
                ),
                if (location != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      '$location',
                      maxLines: 1,
                      style: TextStyle(color: textColor, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (musicName != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}music_stroke_black.svg",
                          defaultColor: false,
                          color: textColor,
                          height: 10,
                        ),
                        Expanded(
                          child: CustomTextWidget(
                            textToDisplay: " $musicName",
                            maxLines: 1,
                            textStyle: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
