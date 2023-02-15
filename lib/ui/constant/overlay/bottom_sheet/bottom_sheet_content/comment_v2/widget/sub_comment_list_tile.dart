import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';

import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';

class SubCommentListTile extends StatefulWidget {
  final String? parentID;
  final DisqusLogs? data;
  final bool fromFront;

  const SubCommentListTile({
    Key? key,
    required this.data,
    required this.parentID,
    required this.fromFront,
  }) : super(key: key);

  @override
  _SubCommentListTileState createState() => _SubCommentListTileState();
}

class _SubCommentListTileState extends State<SubCommentListTile> {
  @override
  Widget build(BuildContext context) {
    final commentor = widget.data?.senderInfo;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * SizeConfig.scaleDiagonal),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(-1.0, 0.0),
            child: CustomProfileImage(
              following: true,
              width: 30 * SizeConfig.scaleDiagonal,
              height: 30 * SizeConfig.scaleDiagonal,
              imageUrl: System().showUserPicture(commentor?.avatar?.mediaEndpoint),
              onTap: () => System().navigateToProfile(context, widget.data?.sender ?? ''),
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
                      text: "@" '${commentor?.username ?? ''}' "   ",
                      style: Theme.of(context).textTheme.caption,
                      children: [
                        TextSpan(
                          text: System().readTimestamp(
                            DateTime.parse(System().dateTimeRemoveT(widget.data?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                            context,
                            fullCaption: true,
                          ),
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 6 * SizeConfig.scaleDiagonal),
                  CustomTextWidget(
                    textToDisplay: widget.data?.txtMessages ?? '',
                    textAlign: TextAlign.start,
                    maxLines: null,
                    textOverflow: TextOverflow.visible,
                    textStyle: Theme.of(context).textTheme.bodyText2,
                  ),
                  SizedBox(height: 9 * SizeConfig.scaleDiagonal),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.fromFront) {
                            ShowBottomSheet.onShowCommentV2(context, postID: notifier.postID);
                          } else {
                            notifier.showTextInput = true;
                            notifier.onReplayCommentV2(
                              context,
                              comment: widget.data,
                              parentCommentID: widget.parentID,
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
                            const CustomTextWidget(
                              textToDisplay: " Reply",
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kHyppeBottomNavBarIcon,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment(1.0, 0.0),
          //   child: CustomIconButtonWidget(
          //     padding: EdgeInsets.all(0),
          //     alignment: Alignment.topRight,
          //     iconData: widget.data.isReacted ? "${AssetPath.vectorPath}liked.svg" : "${AssetPath.vectorPath}unlike.svg",
          //     defaultColor: widget.data.isReacted ? false : true,
          //     onPressed: widget.data.isReacted
          //         ? () => context.read<LikeNotifier>().onLikeComment(context, comment: widget.data)
          //         : () => context.read<LikeNotifier>().showCommentReaction(context, widget.data),
          //   ),
          // ),
        ],
      ),
    );
  }
}
