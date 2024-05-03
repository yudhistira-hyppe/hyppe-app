import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/live_stream/comment_live_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class PinCommenmt extends StatelessWidget {
  const PinCommenmt({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) {
        final tn = context.read<TranslateNotifierV2>().translate;
        return notifier.pinComment == null
            ? Container()
            : GestureDetector(
                onLongPress: () {
                  ShowBottomSheet().onShowCommentOptionLive(context, notifier.pinComment ?? CommentLiveModel(), isReady: true);
                },
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: CustomProfileImage(
                            cacheKey: '',
                            following: true,
                            forStory: false,
                            width: 26 * SizeConfig.scaleDiagonal,
                            height: 26 * SizeConfig.scaleDiagonal,
                            imageUrl: System().showUserPicture(notifier.pinComment?.avatar?.mediaEndpoint ?? ''),
                            // badge: notifier.user.profile?.urluserBadge,
                            allwaysUseBadgePadding: false,
                          ),
                        ),
                        twelvePx,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text.rich(TextSpan(text: notifier.pinComment?.username ?? '', style: const TextStyle(color: Color(0xffcecece), fontWeight: FontWeight.w700))),
                                  sixPx,
                                  const CustomIconWidget(
                                    iconData: "${AssetPath.vectorPath}push-pin.svg",
                                    color: Colors.white,
                                    defaultColor: false,
                                  ),
                                  sixPx,
                                  Text("${tn.pinned?.toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Text(
                                notifier.pinComment?.messages ?? '',
                                style: TextStyle(color: kHyppeTextPrimary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            notifier.removePinComment();
                          },
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.close),
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              );
      },
    );
  }
}
