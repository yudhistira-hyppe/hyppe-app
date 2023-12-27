import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/screen.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/constants/size_config.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../notifier.dart';

class ListCommentViewer extends StatelessWidget {
  final FocusNode? commentFocusNode;
  final LinkStreamModel? data;
  const ListCommentViewer({super.key, this.commentFocusNode, this.data});

  @override
  Widget build(BuildContext context) {
    final debouncer = Debouncer(milliseconds: 2000);
    return Consumer<ViewStreamingNotifier>(
      builder: (context, notifier, __) => SizedBox(
        height: context.getHeight() * (commentFocusNode!.hasFocus ? 0.15 : 0.3),
        width: SizeConfig.screenWidth! * 0.7,
        child: notifier.isCommentDisable
            ? Container()
            : GestureDetector(
                onTap: () {
                  commentFocusNode!.unfocus();
                },
                onDoubleTapDown: (details) {
                  var position = details.globalPosition;
                  notifier.positionDxDy = position;
                },
                onDoubleTap: () {
                  notifier.likeAddTapScreen();
                  debouncer.run(() {
                    notifier.sendLikeTapScreen(context, notifier.streamerData!);
                  });
                },
                child: ListView.builder(
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
                                onTap: () {
                                  if (notifier.currentUserId != notifier.comment[index].sId) {
                                    ShowBottomSheet.onWatcherStatus(context, notifier.comment[index].email ?? '', data?.sId ?? '');
                                  }
                                },
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text.rich(TextSpan(text: notifier.comment[index].username ?? '', style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700), children: [
                                      if (notifier.comment[index].messages == 'joined')
                                        const TextSpan(
                                          text: ' joined',
                                          style: TextStyle(color: kHyppeTextPrimary, fontWeight: FontWeight.w700),
                                        )
                                    ])),
                                    // Text(
                                    //   notifier.comment[index].username ?? '',
                                    //   style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700),
                                    // ),
                                    if (notifier.comment[index].messages != 'joined')
                                      Text(
                                        notifier.comment[index].messages ?? '',
                                        style: const TextStyle(color: kHyppeTextPrimary),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
