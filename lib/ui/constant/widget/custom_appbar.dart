import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/fullscreen/video_fullscreen_page.dart';
import 'custom_icon_widget.dart';
import 'custom_spacer.dart';
import 'profile_component.dart';

class CustomAppBar extends StatelessWidget {
  final Orientation orientation;
  final ContentData data;
  final int currentPosition;
  final int videoDuration;
  final int currentPositionText;
  final bool showTipsWidget;
  final bool isMute;
  final Function()? onTap;
  const CustomAppBar(
      {super.key,
      required this.orientation,
      required this.data,
      required this.onTap,
      this.currentPosition = 0,
      this.videoDuration = 1,
      this.currentPositionText = 0,
      this.showTipsWidget = false,
      this.isMute = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                int changevalue;
                changevalue = currentPosition + 1000;
                if (changevalue > videoDuration) {
                  changevalue = videoDuration;
                }

                data.isLoading = true;
                Navigator.pop(
                    context,
                    VideoIndicator(
                        videoDuration: videoDuration,
                        seekValue: changevalue,
                        positionText: currentPositionText,
                        showTipsWidget: showTipsWidget,
                        isMute: isMute));
              },
              padding: orientation == Orientation.portrait
                  ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 42.0)
                  : const EdgeInsets.symmetric(horizontal: 46.0, vertical: 8.0),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ProfileComponent(
                show: true,
                following: true,
                onFollow: () {},
                username: data.username,
                textColor: kHyppeLightBackground,
                spaceProfileAndId: eightPx,
                haveStory: false,
                isCelebrity: false,
                isUserVerified: data.privacy!.isIdVerified ?? false,
                onTapOnProfileImage: () =>
                    System().navigateToProfile(context, data.email ?? ''),
                featureType: FeatureType.pic,
                imageUrl:
                    '${System().showUserPicture(data.avatar?.mediaEndpoint)}',
                badge: data.urluserBadge,
                createdAt: '${System().readTimestamp(
                  DateTime.parse(System().dateTimeRemoveT(data.createdAt ?? ''))
                      .millisecondsSinceEpoch,
                  context,
                  fullCaption: true,
                )}',
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: actionWidget(onTap: onTap),
        ),
      ],
    );
  }

  Widget actionWidget({Function()? onTap}) {
    return Row(
      children: [
        Visibility(
          visible: (data.saleAmount ?? 0) > 0,
          child: Container(
            padding: EdgeInsets.all(
                data.email == SharedPreference().readStorage(SpKeys.email)
                    ? 2.0
                    : 13),
            child: const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}sale.svg",
              defaultColor: false,
              height: 22,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Icon(
            Icons.more_vert,
            color: kHyppeLightBackground,
          ),
        ),
      ],
    );
  }
}
