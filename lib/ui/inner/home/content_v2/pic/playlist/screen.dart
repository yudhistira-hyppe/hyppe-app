import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/on_show_comment_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/core/arguments/contents/pic_detail_screen_argument.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_slider.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_detail_shimmer.dart';

class PicDetailScreen extends StatefulWidget {
  final PicDetailScreenArgument arguments;

  const PicDetailScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  _PicDetailScreenState createState() => _PicDetailScreenState();
}

class _PicDetailScreenState extends State<PicDetailScreen> with AfterFirstLayoutMixin {
  final _notifier = PicDetailNotifier();

  @override
  void afterFirstLayout(BuildContext context) {
    _notifier.initState(context, widget.arguments);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PicDetailNotifier>(
      create: (context) => _notifier,
      child: Consumer<PicDetailNotifier>(
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
                      _notifier.data != null ? PicDetailSlider(picData: notifier.data) : PicDetailShimmer(),
                      PicDetailBottom(data: notifier.data),
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
