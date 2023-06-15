import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import '../../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../../core/constants/size_config.dart';
import '../../../../../../../../core/services/shared_preference.dart';
import '../../../../../../../../core/services/system.dart';
import '../../../../../../../constant/entities/comment_v2/notifier.dart';
import '../../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../../constant/overlay/general_dialog/show_general_dialog.dart';
import '../../../../../../../constant/widget/custom_desc_content_widget.dart';
import '../../../../../../../constant/widget/custom_profile_image.dart';
import '../../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../../constant/widget/custom_text_widget.dart';
import '../../widget/user_template.dart';

class CommentTile extends StatelessWidget {
  final bool fromFront;
  final CommentsLogs? logs;
  final CommentNotifierV2 notifier;
  final int? index;
  CommentTile({Key? key, required this.logs, required this.fromFront, required this.notifier, this.index}) : super(key: key);

  final email = SharedPreference().readStorage(SpKeys.email);
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CommentTile');
    final comment = logs?.comment;
    final replies = logs?.comment?.detailDisquss;
    final repliesCount = replies?.length ?? 0;
    final commentor = logs?.comment?.senderInfo;
    final _language = notifier.language;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomProfileImage(
                width: 36,
                height: 36,
                onTap: () => System().navigateToProfile(context, logs?.comment?.sender ?? ''),
                imageUrl: System().showUserPicture(commentor?.avatar?.mediaEndpoint),
                following: true,
                onFollow: () {},
              ),
              twelvePx,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserTemplate(username: '${commentor?.username}', isVerified: commentor?.isIdVerified ?? false, date: comment?.createdAt ?? DateTime.now().toString()),
                    twoPx,
                    Row(
                      children: [
                        Expanded(
                          child: CustomDescContent(
                              isloading: false,
                              desc: comment?.txtMessages ?? '',
                              trimLines: 5,
                              textAlign: TextAlign.start,
                              seeLess: ' ${notifier.language.seeLess}',
                              seeMore: ' ${notifier.language.seeMoreContent}',
                              textOverflow: TextOverflow.visible,
                              normStyle: Theme.of(context).textTheme.bodyText2,
                              hrefStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary),
                              expandStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary)),
                        ),
                      ],
                    ),
                    twoPx,
                    InkWell(
                      onTap: () {
                        notifier.showTextInput = true;
                        notifier.onReplayCommentV2(
                          context,
                          comment: comment,
                          parentCommentID: comment?.lineID,
                        );
                      },
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.reply ?? 'Reply',
                        textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    repliesCount > 0 ? SizedBox(height: 16 * SizeConfig.scaleDiagonal) : const SizedBox.shrink(),
                    repliesCount > 0
                        ? InkWell(
                            onTap: () {
                              notifier.seeMoreReplies(logs);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: CustomTextWidget(
                                textStyle: context.getTextTheme().overline?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                textToDisplay: notifier.repliesComments.containsKey(logs?.comment?.lineID)
                                    ? '${_language.hideReplies}'
                                    : "${_language.see} $repliesCount ${repliesCount > 1 ? _language.replies : _language.reply2}",
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
              if (comment?.sender == email)
                InkWell(
                  onTap: () {
                    ShowGeneralDialog.deleteContentDialog(context, '${_language.comment}', () async {
                      notifier.deleteComment(context, comment?.lineID ?? '', comment?.detailDisquss?.length ?? 0, indexComment: index);
                    });
                  },
                  child: CustomIconWidget(
                    width: 20,
                    height: 20,
                    iconData: '${AssetPath.vectorPath}close.svg',
                    defaultColor: false,
                    color: context.getColorScheme().onBackground,
                  ),
                )
            ],
          ),
        ),
        // show sub comments
        notifier.repliesComments.containsKey(comment?.lineID)
            ? Container(
                margin: EdgeInsets.only(left: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: notifier.repliesComments[comment?.lineID] ?? [],
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
