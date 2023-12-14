import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

class ListCommentLive extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const ListCommentLive({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight! * (commentFocusNode!.hasFocus ? 0.15 : 0.3),
      width: SizeConfig.screenWidth! * 0.7,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomProfileImage(
                  cacheKey: '',
                  following: true,
                  forStory: false,
                  width: 26 * SizeConfig.scaleDiagonal,
                  height: 26 * SizeConfig.scaleDiagonal,
                  imageUrl: System().showUserPicture(''),
                  // badge: notifier.user.profile?.urluserBadge,
                  allwaysUseBadgePadding: false,
                ),
                twelvePx,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'marcelardianto',
                        style: TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'kuy makan pizza bareng!!',
                        style: TextStyle(color: kHyppeTextPrimary),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
