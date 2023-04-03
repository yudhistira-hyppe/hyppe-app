import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_stroke_text_widget.dart';

import '../../../core/constants/asset_path.dart';
import 'custom_icon_widget.dart';
import 'custom_profile_image.dart';
import 'custom_spacer.dart';
import 'custom_text_widget.dart';
import 'custom_verified_widget.dart';
import 'story_color_validator.dart';

class ProfileComponent extends StatelessWidget {
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
  final bool isUserVerified;

  const ProfileComponent(
      {Key? key,
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
      required this.featureType,
      required this.isUserVerified})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Visibility(
      visible: show,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StoryColorValidator(
                haveStory: haveStory,
                featureType: featureType,
                child: CustomProfileImage(
                  cacheKey: cacheKey,
                  width: widthCircle,
                  height: heightCircle,
                  onTap: onTapOnProfileImage,
                  imageUrl: imageUrl,
                  following: following,
                  onFollow: onFollow,
                ),
              ),
              Visibility(visible: showNameAndTimeStamp, child: spaceProfileAndId),
              Visibility(
                visible: showNameAndTimeStamp,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: SizeWidget().calculateSize(widthText, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()),
                      child: Row(
                        children: [
                          Flexible(
                            child: isDetail
                                ? CustomStrokeTextWidget(
                                    textToDisplay: username ?? '',
                                    maxLines: 1,
                                    textStyle: Theme.of(context).textTheme.button,
                                    textAlign: TextAlign.left,
                                  )
                                : CustomTextWidget(
                                    textToDisplay: username ?? '',
                                    maxLines: 1,
                                    textStyle: Theme.of(context).textTheme.button?.copyWith(color: textColor),
                                    textAlign: TextAlign.left,
                                  ),
                          ),
                          if(isUserVerified)
                          twoPx,
                          if(isUserVerified)
                          const CustomIconWidget(
                            iconData: '${AssetPath.vectorPath}ic_verified.svg',
                            defaultColor: false,
                            width: 16,
                            height: 16,
                          ),
                          tenPx,
                          CustomVerifiedWidget(verified: isCelebrity)
                        ],
                      ),
                    ),
                    SizedBox(
                      width: SizeWidget().calculateSize(widthText, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()),
                      child: isDetail
                          ? CustomStrokeTextWidget(
                              maxLines: 1,
                              textToDisplay: createdAt,
                              textAlign: TextAlign.left,
                              textStyle: Theme.of(context).textTheme.caption,
                            )
                          : CustomTextWidget(
                              maxLines: 1,
                              textToDisplay: createdAt,
                              textAlign: TextAlign.left,
                              textStyle: Theme.of(context).textTheme.caption?.copyWith(color: textColor),
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
          // GestureDetector(onTap: () => onReport, child: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }
}
