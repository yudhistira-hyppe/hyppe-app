import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../core/models/collection/comment_v2/comment_data_v2.dart';
import '../../../../../../../../core/services/system.dart';
import '../../../../../../../constant/entities/comment_v2/notifier.dart';
import '../../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../../constant/widget/custom_text_widget.dart';
import '../../widget/user_template.dart';

class SubCommentTile extends StatelessWidget {
  final String? parentID;
  final DisqusLogs? logs;
  final bool fromFront;
  SubCommentTile({Key? key, required this.logs,
    required this.parentID,
    required this.fromFront,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final commentor = logs?.senderInfo;
    final notifier = context.read<CommentNotifierV2>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomProfileImage(
            width: 36,
            height: 36,
            onTap: () {},
            imageUrl: System()
                .showUserPicture(commentor?.avatar?.mediaEndpoint),
            following: true,
            onFollow: () {},
          ),
          twelvePx,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserTemplate(username: '${commentor?.username}', isVerified: commentor?.isIdVerified ?? false, date:
                logs?.createdAt ??
                    DateTime.now().toString()
                ),
                twoPx,
                Row(
                  children: [
                    Expanded(
                      child: CustomTextWidget(
                        textAlign: TextAlign.start,
                        textToDisplay:
                        '${logs?.txtMessages}',
                        maxLines: 2,
                        textStyle: context
                            .getTextTheme()
                            .caption
                            ?.copyWith(
                            color: context
                                .getColorScheme()
                                .onBackground),
                      ),
                    ),
                  ],
                ),
                twoPx,
                InkWell(
                  onTap: (){
                    if (fromFront) {
                      ShowBottomSheet.onShowCommentV2(context, postID: notifier.postID);
                    } else {
                      notifier.showTextInput = true;
                      notifier.onReplayCommentV2(
                        context,
                        comment: logs,
                        parentCommentID: parentID,
                      );
                    }
                  },
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.reply ?? 'Reply',
                    textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().primary, fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
