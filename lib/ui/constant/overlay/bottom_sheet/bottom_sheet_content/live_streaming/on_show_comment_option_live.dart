import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnShowCommentOptionLiveBottomSheet extends StatefulWidget {
  final CommentLiveModel dataComment;
  final bool? isReady;
  const OnShowCommentOptionLiveBottomSheet({Key? key, required this.dataComment, this.isReady}) : super(key: key);

  @override
  State<OnShowCommentOptionLiveBottomSheet> createState() => _OnShowCommentOptionLiveBottomSheetState();
}

class _OnShowCommentOptionLiveBottomSheetState extends State<OnShowCommentOptionLiveBottomSheet> {
  PageController? controller = PageController();
  bool firstTab = true;

  @override
  Widget build(BuildContext context) {
    var language = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (context, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", color: Color(0xffcecece), defaultColor: false),
          ),
          twentyEightPx,
          CustomProfileImage(
            width: 56,
            height: 56,
            following: true,
            imageUrl: System().showUserPicture(widget.dataComment.avatar?.mediaEndpoint),
          ),
          sixteenPx,
          Text(
            widget.dataComment.username ?? '',
            style: TextStyle(color: kHyppeTextLightPrimary, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          sixPx,
          Text(
            widget.dataComment.fullName ?? '',
            style: const TextStyle(color: kHyppeBurem, fontSize: 12),
          ),
          sixteenPx,
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              language.deleteComment?.replaceAll('?', '') ?? '',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: kHyppeBgNotSolve,
              height: 1,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.isReady ?? false) {
                notifier.removePinComment();
              } else {
                notifier.insertPinComment(widget.dataComment);
              }
              Routing().moveBack();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                (widget.isReady ?? false) ? language.unpinComment?.replaceAll('?', '') ?? '' : language.pinComment?.replaceAll('?', '') ?? '',
                // style: TextStyle(),
              ),
            ),
          ),
          twentyEightPx,
        ],
      ),
    );
  }
}
