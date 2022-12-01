import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
// import 'package:hyppe/core/models/collection/notifications/notifications_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Component extends StatelessWidget {
  final Widget rightWidget;
  final NotificationModel? data;

  const Component({Key? key, required this.rightWidget, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      onTap: () {
        context.read<NotificationNotifier>().markAsRead(context, data ?? NotificationModel());
        final eventType = System().getNotificationCategory(data?.eventType ?? '');

        switch (eventType) {
          case NotificationCategory.transactions:
            Routing().move(Routes.transaction);
            break;
          case NotificationCategory.all:
            // TODO: Handle this case.
            break;
          case NotificationCategory.like:
            context.read<NotificationNotifier>().navigateToContent(context, data?.content?.postType, data?.postID);
            break;
          case NotificationCategory.comment:
            context.read<NotificationNotifier>().navigateToContent(context, data?.content?.postType, data?.postID);
            break;
          case NotificationCategory.follower:
            // TODO: Handle this case.
            break;
          case NotificationCategory.following:
            // TODO: Handle this case.
            break;
          case NotificationCategory.mention:
            context.read<NotificationNotifier>().navigateToContent(context, data?.content?.postType, data?.postID);
            break;
          case NotificationCategory.general:
            // TODO: Handle this case.
            break;
          case NotificationCategory.verificationid:
            // TODO: Handle this case.
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // profile picture

            StoryColorValidator(
              featureType: FeatureType.other,
              haveStory: false,
              child: CustomProfileImage(
                following: true,
                width: 50 * SizeConfig.scaleDiagonal,
                height: 50 * SizeConfig.scaleDiagonal,
                onTap: () => System().navigateToProfile(context, data?.mate ?? ''),
                imageUrl: '${System().showUserPicture(data?.senderOrReceiverInfo?.avatar?.mediaEndpoint)}',
              ),
            ),
            sixteenPx,
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // title and subtitle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        textToDisplay: data?.senderOrReceiverInfo?.fullName ?? '',
                        textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      fourPx,
                      SizedBox(
                        width: data?.body != null
                            ? data!.body!.length < 30
                                ? null
                                : SizeConfig.screenWidth! / 1.5
                            : null,
                        child: CustomTextWidget(
                          //textToDisplay: data?.body ?? '',
                          textToDisplay: System().bodyMultiLang(bodyEn: data?.body ?? data?.bodyId, bodyId: data?.bodyId) ?? '',
                          textStyle: Theme.of(context).textTheme.caption,
                          maxLines: 4,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      sixPx,
                      CustomTextWidget(
                        textToDisplay:
                            data?.createdAt != null ? System().readTimestamp(DateFormat("yyyy-MM-dd hh:mm:ss").parse(data?.createdAt ?? '').millisecondsSinceEpoch, context, fullCaption: true) : '',
                        textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant),
                      ),
                    ],
                  ),
                  rightWidget
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
