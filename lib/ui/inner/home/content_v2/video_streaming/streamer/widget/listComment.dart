import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class ListCommentLive extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const ListCommentLive({super.key, this.commentFocusNode});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => SizedBox(
        height: SizeConfig.screenHeight! * (commentFocusNode!.hasFocus ? 0.15 : 0.3),
        width: SizeConfig.screenWidth! * 0.7,
        child: notifier.isCommentDisable
            ? Container()
            : ListView.builder(
                reverse: true,
                shrinkWrap: true,
                itemCount: notifier.comment.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () {
                      // ShowBottomSheet.onWatcherStatus(context, notifier.comment[index].email ?? '');
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => ShowBottomSheet.onWatcherStatus(context, notifier.comment[index].email ?? ''),
                              child: CustomProfileImage(
                                cacheKey: '',
                                following: true,
                                forStory: false,
                                width: 26 * SizeConfig.scaleDiagonal,
                                height: 26 * SizeConfig.scaleDiagonal,
                                imageUrl: System().showUserPicture(
                                  notifier.comment[index].avatar?.mediaEndpoint,
                                ),
                                // badge: notifier.user.profile?.urluserBadge,
                                allwaysUseBadgePadding: false,
                              ),
                            ),
                            twelvePx,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notifier.comment[index].username ?? '',
                                    style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    notifier.comment[index].messages ?? '',
                                    style: const TextStyle(color: kHyppeTextPrimary),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
