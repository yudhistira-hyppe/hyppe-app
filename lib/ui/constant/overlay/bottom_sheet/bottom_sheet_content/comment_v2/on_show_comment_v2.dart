import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/widget/comment_slider.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/widget/comment_list_tile.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/comment_v2/widget/comment_text_field.dart';

class OnShowCommentBottomSheetV2 extends StatefulWidget {
  final String? postID;
  final bool fromFront;
  final DisqusLogs? parentComment;

  const OnShowCommentBottomSheetV2({
    Key? key,
    this.parentComment,
    required this.postID,
    required this.fromFront,
  }) : super(key: key);

  @override
  _OnShowCommentBottomSheetV2State createState() => _OnShowCommentBottomSheetV2State();
}

class _OnShowCommentBottomSheetV2State extends State<OnShowCommentBottomSheetV2> {
  final _notifier = CommentNotifierV2();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _notifier.initState(context, widget.postID, widget.fromFront, widget.parentComment);
    _scrollController.addListener(() => _notifier.scrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notifier.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ChangeNotifierProvider<CommentNotifierV2>(
      create: (context) => _notifier,
      child: Consumer<CommentNotifierV2>(
        builder: (_, notifier, __) {
          if (notifier.commentData == null) {
            return const Center(child: CustomLoading());
          }

          return Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (widget.fromFront)
                      eightPx
                    else
                      CommentSlider(
                        length: notifier.commentData?.length,
                      ),
                    Expanded(
                      child: !notifier.isCommentEmpty
                          ? ListView.separated(
                              itemCount: notifier.itemCount,
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 10),
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              separatorBuilder: (context, index) => const Divider(
                                thickness: 0.95,
                                color: Color(0xff2E3338),
                              ),
                              itemBuilder: (context, index) {
                                if (index == notifier.commentData?.length && notifier.hasNext) {
                                  return const CustomLoading();
                                }

                                final comments = notifier.commentData?[index];

                                return CommentListTile(
                                  data: comments,
                                  fromFront: widget.fromFront,
                                );
                              },
                            )
                          : UnconstrainedBox(
                              child: CustomTextButton(
                                onPressed: () {
                                  if (widget.fromFront) {
                                    ShowBottomSheet.onShowCommentV2(context, postID: notifier.postID);
                                  } else {
                                    notifier.showTextInput = true;
                                  }
                                },
                                child: CustomTextWidget(textToDisplay: context.read<TranslateNotifierV2>().translate.beTheFirstToComment!),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              CommentTextField(fromFront: widget.fromFront)
            ],
          );
        },
      ),
    );
  }
}
