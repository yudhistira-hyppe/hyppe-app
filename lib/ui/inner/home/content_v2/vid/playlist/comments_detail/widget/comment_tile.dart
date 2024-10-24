import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/comment_v2/comment_data_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import '../../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../../core/constants/size_config.dart';
import '../../../../../../../../core/services/shared_preference.dart';
import '../../../../../../../../core/services/system.dart';
import '../../../../../../../constant/entities/comment_v2/notifier.dart';
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
  CommentTile(
      {Key? key,
      required this.logs,
      required this.fromFront,
      required this.notifier,
      this.index})
      : super(key: key);

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
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomProfileImage(
                width: 36,
                height: 36,
                onTap: () => System()
                    .navigateToProfile(context, logs?.comment?.sender ?? ''),
                imageUrl:
                    System().showUserPicture(commentor?.avatar?.mediaEndpoint),
                badge: commentor?.urluserBadge,
                following: true,
                onFollow: () {},
              ),
              twelvePx,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserTemplate(
                        username: '${commentor?.username}',
                        isVerified: commentor?.isIdVerified ?? false,
                        date: comment?.createdAt ?? DateTime.now().toString()),
                    twoPx,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (comment?.txtMessages != '')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    fivePx,
                                    CustomDescContent(
                                      isloading: false,
                                      desc: comment?.txtMessages ?? '',
                                      trimLines: 5,
                                      textAlign: TextAlign.start,
                                      seeLess: ' ${notifier.language.seeLess}',
                                      seeMore:
                                          ' ${notifier.language.seeMoreContent}',
                                      textOverflow: TextOverflow.visible,
                                      normStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      hrefStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                      expandStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ],
                                ),
                              if (comment!.gift != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    fivePx,
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 2, left: 4, right: 4, bottom: 2),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xffF56DA7)
                                                  .withOpacity(0.4),
                                              const Color(0xffffffff)
                                                  .withOpacity(0.5)
                                            ],
                                            stops: const [0.25, 0.75],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          fivePx,
                                          Text(
                                            notifier.language.localeDatetime ==
                                                    'id'
                                                ? 'Terkirim '
                                                : 'Send to ',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 14),
                                            width:
                                                35 * SizeConfig.scaleDiagonal,
                                            height:
                                                35 * SizeConfig.scaleDiagonal,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        comment?.gift ?? ''))),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                    fivePx,
                    InkWell(
                      onTap: () {
                        context.handleActionIsGuest(() async {
                          notifier.showTextInput = true;
                          notifier.onReplayCommentV2(
                            context,
                            comment: comment,
                            parentCommentID: comment.lineID,
                          );
                        });
                      },
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.reply ?? 'Reply',
                        textStyle: context.getTextTheme().labelMedium?.copyWith(
                            color: context.getColorScheme().primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    repliesCount > 0
                        ? SizedBox(height: 16 * SizeConfig.scaleDiagonal)
                        : const SizedBox.shrink(),
                    repliesCount > 0
                        ? InkWell(
                            onTap: () {
                              notifier.seeMoreReplies(logs);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: CustomTextWidget(
                                textStyle: context
                                    .getTextTheme()
                                    .labelSmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                textToDisplay: notifier.repliesComments
                                        .containsKey(logs?.comment?.lineID)
                                    ? '${_language.hideReplies}'
                                    : "⎯⎯⎯     ${_language.see} $repliesCount ${repliesCount > 1 ? _language.replies : _language.reply2}",
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
                    context.handleActionIsGuest(() async {
                      ShowGeneralDialog.deleteContentDialog(
                          context, '${_language.comment}', () async {
                        notifier.deleteComment(
                          context,
                          comment.lineID ?? '',
                          comment.detailDisquss?.length ?? 0,
                          indexComment: index,
                        );
                      });
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
