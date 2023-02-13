import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/on_show_comment_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/vid_detail_top.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';

import 'package:hyppe/core/arguments/contents/vid_detail_screen_argument.dart';

import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_player_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/vid_detail_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/playlist/widget/vid_detail_shimmer.dart';

class VidDetailScreen extends StatefulWidget {
  final VidDetailScreenArgument arguments;

  const VidDetailScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  _VidDetailScreenState createState() => _VidDetailScreenState();
}

class _VidDetailScreenState extends State<VidDetailScreen> with AfterFirstLayoutMixin {
  final _notifier = VidDetailNotifier();

  @override
  void afterFirstLayout(BuildContext context) {
    _notifier.initState(context, widget.arguments);
    if (widget.arguments.vidData?.certified ?? false) {
      System().block(context);
    } else {
      System().disposeBlock();
    }
  }

  @override
  void dispose() {
    System().disposeBlock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VidDetailNotifier>(
      create: (context) => _notifier,
      child: Consumer<VidDetailNotifier>(
        builder: (_, notifier, __) {
          return WillPopScope(
            onWillPop: notifier.onPop,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      VidDetailTop(data: notifier.data),
                      _notifier.data != null
                          ? Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Container(
                                    color: Colors.black,
                                    child: VideoPlayerPage(
                                      videoData: notifier.data,
                                      afterView: () => notifier.updateView(context),
                                    ),
                                  ),
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Visibility(
                                //       visible: true,
                                //       child: CustomTextButton(
                                //         onPressed: () => notifier.onPop(),
                                //         child: const DecoratedIconWidget(
                                //           Icons.arrow_back_ios,
                                //           size: 48 * 0.4,
                                //           color: Colors.white,
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            )
                          : VidDetailShimmer(),
                      VidDetailBottom(data: notifier.data),
                      _notifier.data != null && (_notifier.data?.allowComments ?? false)
                          ? Expanded(
                              child: OnShowCommentBottomSheetV2(
                              fromFront: true,
                              postID: _notifier.data?.postID,
                            ))
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
