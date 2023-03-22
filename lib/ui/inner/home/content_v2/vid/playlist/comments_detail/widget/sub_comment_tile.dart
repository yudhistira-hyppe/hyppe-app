import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../../core/models/collection/comment_v2/comment_data_v2.dart';
import '../../../../../../../../core/services/shared_preference.dart';
import '../../../../../../../../core/services/system.dart';
import '../../../../../../../constant/entities/comment_v2/notifier.dart';
import '../../../../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../../../../constant/overlay/general_dialog/show_general_dialog.dart';
import '../../../../../../../constant/widget/custom_desc_content_widget.dart';
import '../../../../../../../constant/widget/custom_icon_widget.dart';
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

  final email = SharedPreference().readStorage(SpKeys.email);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SubCommentTile');
    final commentor = logs?.senderInfo;
    final notifier = context.read<CommentNotifierV2>();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomProfileImage(
            width: 36,
            height: 36,
            onTap: () => System().navigateToProfile(context, logs?.sender ?? ''),
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
                      child: CustomDescContent(
                          desc: '${logs?.txtMessages}',
                          trimLines: 5,
                          textAlign: TextAlign.start,
                          seeLess: ' ${notifier.language.seeLess}',
                          seeMore: ' ${notifier.language.seeMoreContent}',
                          textOverflow: TextOverflow.visible,
                          normStyle: Theme.of(context).textTheme.bodyText2,
                          hrefStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary),
                          expandStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    )
                    ,
                  ],
                ),
                twoPx,
                InkWell(
                  onTap: (){
                    notifier.showTextInput = true;
                    notifier.onReplayCommentV2(
                      context,
                      comment: logs,
                      parentCommentID: parentID,
                    );
                  },
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.reply ?? 'Reply',
                    textStyle: context.getTextTheme().overline?.copyWith(color: context.getColorScheme().primary, fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ),
          if(logs?.sender == email)
            InkWell(
              onTap: (){
                ShowGeneralDialog.deleteContentDialog(context, '${notifier.language.comment}', () async {
                  notifier.deleteComment(context, logs?.lineID ?? '');
                });
              },
              child: CustomIconWidget(width: 20, height: 20, iconData: '${AssetPath.vectorPath}close.svg', defaultColor: false, color: context.getColorScheme().onBackground,),
            )
        ],
      ),
    );
  }
}
