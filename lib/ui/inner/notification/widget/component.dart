import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
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

class Component extends StatefulWidget {
  final Widget rightWidget;
  final NotificationModel? data;

  const Component({Key? key, required this.rightWidget, this.data}) : super(key: key);

  @override
  State<Component> createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Component');
    SizeConfig().init(context);
    return InkWell(
      onTap: () async {
        if(!isLoading){
          setState(() {
            isLoading = true;
          });
          context.read<NotificationNotifier>().markAsRead(context, widget.data ?? NotificationModel());
          final eventType = System().getNotificationCategory(widget.data?.eventType ?? '');
          var listTransacation = [
            NotificationCategory.transactions,
            NotificationCategory.adsClick,
            NotificationCategory.adsView,
          ];

          if (listTransacation.contains(eventType)) {
            await Routing().move(Routes.transaction);
          } else {
            await context.read<NotificationNotifier>().navigateToContent(context, widget.data?.postType, widget.data?.postID);
          }
        }
        setState(() {
          isLoading = false;
        });
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
                onTap: () => System().navigateToProfile(context, widget.data?.mate ?? ''),
                imageUrl: '${System().showUserPicture(widget.data?.senderOrReceiverInfo?.avatar?.mediaEndpoint)}',
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
                        textToDisplay: widget.data?.senderOrReceiverInfo?.username ?? '',
                        textAlign: TextAlign.start,
                        textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      fourPx,
                      SizedBox(
                        width: (SizeConfig.screenWidth ?? 0) / 1.8,
                        // data?.content != null
                        //     ? (SizeConfig.screenWidth ?? 0) / 1.8
                        //     : data?.body != null
                        //         ? (data?.body?.length ?? 0) < 34
                        //             ? null
                        //             : (SizeConfig.screenWidth ?? 0) / 1.5
                        //         : null,
                        child: CustomTextWidget(
                          //textToDisplay: data?.body ?? '',
                          textToDisplay: System().bodyMultiLang(bodyEn: widget.data?.body ?? widget.data?.bodyId, bodyId: widget.data?.bodyId) ?? '',
                          textStyle: Theme.of(context).textTheme.caption,
                          maxLines: 4,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      sixPx,
                      CustomTextWidget(
                        textToDisplay:
                        widget.data?.createdAt != null ? System().readTimestamp(DateFormat("yyyy-MM-dd hh:mm:ss").parse(widget.data?.createdAt ?? '').millisecondsSinceEpoch, context, fullCaption: true) : '',
                        textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                  isLoading ? const CircularProgressIndicator() : widget.rightWidget
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

