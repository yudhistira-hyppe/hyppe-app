import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/video_fullscreen_page.dart';
import 'package:provider/provider.dart';
import 'custom_icon_widget.dart';
import 'custom_spacer.dart';
import 'profile_component.dart';

class CustomAppBar extends StatelessWidget {
  final Orientation orientation;
  final LocalizationModelV2 lang;
  final ContentData? data;
  final String? email;
  final int currentPosition;
  final int videoDuration;
  final int currentPositionText;
  final bool showTipsWidget;
  final bool isMute;
  final bool isVidFormProfile;
  final Function()? onTap;
  final Function onTapOnProfileImage;
  const CustomAppBar(
      {super.key,
      required this.orientation,
      required this.data,
      required this.onTap,
      required this.email,
      required this.lang,
      this.currentPosition = 0,
      this.isVidFormProfile = false,
      this.videoDuration = 1,
      this.currentPositionText = 0,
      this.showTipsWidget = false,
      required this.onTapOnProfileImage,
      this.isMute = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                onPressed: () {
                  int changevalue;
                  changevalue = currentPosition + 1000;
                  if (changevalue > videoDuration) {
                    changevalue = videoDuration;
                  }

                  data!.isLoading = true;
                  Navigator.pop(context, VideoIndicator(videoDuration: videoDuration, seekValue: changevalue, positionText: currentPositionText, showTipsWidget: showTipsWidget, isMute: isMute));

                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                },
                padding: orientation == Orientation.portrait ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40.0) : const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: orientation == Orientation.portrait ? const EdgeInsets.only(top: 32.0) : const EdgeInsets.only(top: 8.0),
                child: ProfileComponent(
                  isFullscreen: true,
                  show: true,
                  following: true,
                  onFollow: () {},
                  username: data!.username ?? '',
                  widthText: data!.username!.length >= 10 ? 120 : 90,
                  textColor: kHyppeLightBackground,
                  spaceProfileAndId: eightPx,
                  haveStory: false,
                  isCelebrity: false,
                  isUserVerified: data!.privacy?.isIdVerified ?? false,
                  onTapOnProfileImage: onTapOnProfileImage,
                  featureType: FeatureType.pic,
                  imageUrl: '${System().showUserPicture(data!.avatar?.mediaEndpoint ?? '')}',
                  badge: data!.urluserBadge,
                  createdAt: '${System().readTimestamp(
                    DateTime.parse(System().dateTimeRemoveT(data!.createdAt ?? '')).millisecondsSinceEpoch,
                    context,
                    fullCaption: true,
                  )}',
                ),
              ),
              if (data!.email != email && (data!.isNewFollowing ?? false) && !isVidFormProfile)
                Consumer<PreviewPicNotifier>(
                  builder: (context, picNot, child) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        context.handleActionIsGuest(() async {
                          if (data!.insight?.isloadingFollow != true) {
                            picNot.followUser(context, data ?? ContentData(), isUnFollow: data!.following, isloading: data!.insight!.isloadingFollow ?? false);
                          }
                        });
                      },
                      child: data?.insight?.isloadingFollow ?? false
                          ? Container(
                              margin: orientation == Orientation.portrait ? const EdgeInsets.only(top: 32.0) : const EdgeInsets.only(top: 8.0),
                              height: 40,
                              width: 30,
                              child: const Center(
                                child: CustomLoading(),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(8),
                              margin: orientation == Orientation.portrait ? const EdgeInsets.only(top: 32.0) : const EdgeInsets.only(top: 8.0),
                              decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(8.0)),
                              child: Text(
                                (data!.following ?? false) ? (lang.following ?? '') : (lang.follow ?? ''),
                                style: const TextStyle(color: kHyppeLightButtonText, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
          Align(alignment: Alignment.bottomCenter, child: actionWidget(onTap: onTap)),
        ],
      ),
    );
  }

  Widget actionWidget({Function()? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: ((data!.saleAmount ?? 0) > 0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: data!.email == SharedPreference().readStorage(SpKeys.email) ? 2.0 : 13, vertical: 12),
            child: const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}sale.svg",
              defaultColor: false,
              height: 28,
            ),
          ),
        ),
        Visibility(
          visible: ((data!.certified ?? false) && (data!.saleAmount ?? 0) == 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const CustomIconWidget(
              iconData: '${AssetPath.vectorPath}ownership.svg',
              defaultColor: false,
              height: 28,
            ),
          ),
        ),
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.more_vert,
            color: kHyppeLightBackground,
          ),
        ),
      ],
    );
  }
}
