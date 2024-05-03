import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/formComment.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/listComment.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/listGifBasic.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/pinComment.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/statusNControl.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/titleLive.dart';

class StreamerWidget extends StatelessWidget {
  final FocusNode? commentFocusNode;
  const StreamerWidget({super.key, this.commentFocusNode});

  Widget interactive(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(bottom: 20), child: ListGift()),
          ListCommentLive(commentFocusNode: commentFocusNode),
          const PinCommenmt(),
          fifteenPx,
          FormCommentLive(commentFocusNode: commentFocusNode),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [TitleLive(), sixteenPx, StatusNControl()],
          ),
          const Spacer(),
          interactive(context),
        ],
      ),
    ));
  }
}
