import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';

class CommentListTile extends StatefulWidget {
  final bool fromFront;
  final CommentsLogs? data;

  const CommentListTile({
    Key? key,
    this.data,
    required this.fromFront,
  }) : super(key: key);

  @override
  _CommentListTileState createState() => _CommentListTileState();
}

class _CommentListTileState extends State<CommentListTile> {
  final email = SharedPreference().readStorage(SpKeys.email);
  @override
  Widget build(BuildContext context) {
    final comment = widget.data?.comment;
    final replies = widget.data?.replies;
    final repliesCount = replies?.length ?? 0;
    final commentor = widget.data?.comment?.senderInfo;
    final _language = context.watch<TranslateNotifierV2>().translate;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * SizeConfig.scaleDiagonal),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: const Alignment(-1.0, 0.0),
                child: CustomProfileImage(
                  following: true,
                  width: 30 * SizeConfig.scaleDiagonal,
                  height: 30 * SizeConfig.scaleDiagonal,
                  imageUrl: System().showUserPicture(commentor?.avatar?.mediaEndpoint),
                  badge: commentor?.urluserBadge,
                  onTap: () => System().navigateToProfile(context, comment?.sender ?? ''),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 42 * SizeConfig.scaleDiagonal),
                child: Consumer<CommentNotifierV2>(
                  builder: (_, notifier, __) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomRichTextWidget(
                        textAlign: TextAlign.start,
                        textSpan: TextSpan(
                          style: Theme.of(context).textTheme.caption,
                          text: commentor?.username != null ? "@" + (commentor?.username ?? '') + "   " : '',
                          children: [
                            TextSpan(
                              text: System().readTimestamp(
                                DateTime.parse(System().dateTimeRemoveT(widget.data?.comment?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                                context,
                                fullCaption: true,
                              ),
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 6 * SizeConfig.scaleDiagonal),
                      if (comment?.txtMessages != '')
                      CustomDescContent(
                          desc: comment?.txtMessages ?? '',
                          trimLines: 5,
                          textAlign: TextAlign.start,
                          seeLess: ' ${_language.less}',
                          seeMore: ' ${_language.more}',
                          textOverflow: TextOverflow.visible,
                          normStyle: Theme.of(context).textTheme.bodyText2,
                          hrefStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppePrimary),
                          expandStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      if (comment!.gift !=  null)
                        Container(
                          padding: const EdgeInsets.only(
                              top: 2, left: 4, right: 4, bottom: 2),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xffF56DA7)
                                      .withOpacity(0.4),
                                  const Color(0xffffffff).withOpacity(0.5)
                                ],
                                stops: const [0.25, 0.75],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(40)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              fivePx,
                              Text(
                                notifier.language.localeDatetime == 'id'
                                    ? 'Terkirim '
                                    : 'Send to ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 16),
                                width: 35 * SizeConfig.scaleDiagonal,
                                height: 35 * SizeConfig.scaleDiagonal,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(comment?.gift??''))),
                              )
                            ],
                          ),
                        ),
                      SizedBox(height: 9 * SizeConfig.scaleDiagonal),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (widget.fromFront) {
                                ShowBottomSheet.onShowCommentV2(
                                  context,
                                  parentComment: comment,
                                  postID: notifier.postID,
                                );
                              } else {
                                notifier.showTextInput = true;
                                notifier.onReplayCommentV2(
                                  context,
                                  comment: comment,
                                  parentCommentID: comment?.lineID,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  width: 20 * SizeConfig.scaleDiagonal,
                                  height: 20 * SizeConfig.scaleDiagonal,
                                  iconData: "${AssetPath.vectorPath}comment.svg",
                                ),
                                CustomTextWidget(
                                  textToDisplay: " ${_language.reply}",
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kHyppeBottomNavBarIcon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      repliesCount > 0 ? SizedBox(height: 16 * SizeConfig.scaleDiagonal) : const SizedBox.shrink(),
                      repliesCount > 0
                          ? InkWell(
                              onTap: () {
                                notifier.seeMoreReplies(widget.data);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: CustomTextWidget(
                                  textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                  textToDisplay: notifier.repliesComments.containsKey(widget.data?.comment?.lineID)
                                      ? '${_language.hideReplies}'
                                      : "${_language.see} $repliesCount ${repliesCount > 1 ? _language.replies : _language.reply2}",
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),

                      // show sub comments
                      // notifier.repliesComments.containsKey(comment?.lineID)
                      //     ? Column(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: notifier.repliesComments[comment?.lineID] ?? [],
                      //       )
                      //     : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              widget.data?.comment?.sender == email
                  ? Consumer<CommentNotifierV2>(
                      builder: (_, notifier, __) => Align(
                          alignment: const Alignment(1.0, 0.0),
                          child: InkWell(
                              onTap: () async {
                                ShowGeneralDialog.deleteContentDialog(context, '${_language.comment}', () async {
                                  notifier.deleteComment(context, comment?.lineID ?? '', comment?.detailDisquss?.length ?? 0);
                                });
                              },
                              child: const Icon(Icons.close))),
                    )
                  : const SizedBox(),
            ],
          ),
          Consumer<CommentNotifierV2>(
            builder: (_, comnotval, __) {
              return comnotval.repliesComments.containsKey(comment?.lineID)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: comnotval.repliesComments[comment?.lineID] ?? [],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}
