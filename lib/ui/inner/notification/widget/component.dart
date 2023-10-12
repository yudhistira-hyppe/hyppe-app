import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
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
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../constant/widget/custom_icon_widget.dart';

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
    final isAnnouncement = widget.data?.actionButtons != null && widget.data?.eventType == 'GENERAL';
    return InkWell(
      onTap: () async {
        if (widget.data?.eventType != 'CONTENTMOD') {
          if (isAnnouncement) {
            final url = widget.data?.actionButtons;
            if (url?.trim().isNotEmpty ?? false) {
              var fixUrl = url;
              if (!fixUrl!.withHttp()) {
                fixUrl = 'https://$fixUrl';
              }
              final allow = Uri.parse(fixUrl).isAbsolute;
              if (allow) {
                try {
                  final uri = Uri.parse(fixUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw "Could not launch $uri";
                  }
                  // can't launch url, there is some error
                } catch (e) {
                  // System().goToWebScreen(data.adsUrlLink ?? '', isPop: true);
                  e.logger();
                }
              }
            }
          } else if (!isLoading) {
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

            print("asdasdasd ${widget.data?.eventType}");
            print("asdasdasd $eventType");

            if (listTransacation.contains(eventType)) {
              await Routing().move(Routes.transaction);
            } else if (NotificationCategory.challange == eventType) {
              await Routing().move(Routes.chalengeDetail, argument: GeneralArgument()..id = widget.data?.postID);
            } else {
              await context.read<NotificationNotifier>().navigateToContent(context, widget.data?.postType, widget.data?.postID);
            }
          }
          setState(() {
            isLoading = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // profile picture
            widget.data?.eventType == 'CHALLENGE'
                ? Container(
                    padding: EdgeInsets.all(16 * SizeConfig.scaleDiagonal),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe8e8e8),
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                    ),
                    child: CustomIconWidget(
                      width: 20 * SizeConfig.scaleDiagonal,
                      height: 20 * SizeConfig.scaleDiagonal,
                      iconData: "${AssetPath.vectorPath}notification-active.svg",
                      defaultColor: false,
                      color: const Color(0xFFcecece),
                    ),
                  )
                : isAnnouncement
                    ? CustomIconWidget(
                        width: 50 * SizeConfig.scaleDiagonal,
                        height: 50 * SizeConfig.scaleDiagonal,
                        iconData: "${AssetPath.vectorPath}ic_rounded_hyppe.svg",
                        defaultColor: false,
                      )
                    : StoryColorValidator(
                        featureType: FeatureType.other,
                        haveStory: false,
                        child: CustomProfileImage(
                          following: true,
                          width: 50 * SizeConfig.scaleDiagonal,
                          height: 50 * SizeConfig.scaleDiagonal,
                          onTap: () => System().navigateToProfile(context, widget.data?.mate ?? ''),
                          imageUrl: '${System().showUserPicture(widget.data?.senderOrReceiverInfo?.avatar?.mediaEndpoint)}',
                          badge: widget.data?.urluserBadge,
                        ),
                      ),
            sixteenPx,
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textToDisplay: widget.data?.eventType == 'CHALLENGE'
                              ? widget.data?.title ?? ''
                              : isAnnouncement
                                  ? (System().bodyMultiLang(bodyEn: widget.data?.titleEN ?? widget.data?.title, bodyId: widget.data?.title) ?? '')
                                  : widget.data?.senderOrReceiverInfo?.username ?? '',
                          textAlign: TextAlign.start,
                          textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(fontWeight: FontWeight.bold),
                          textOverflow: TextOverflow.fade,
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
                          textToDisplay: widget.data?.createdAt != null
                              ? System().readTimestamp(DateFormat("yyyy-MM-dd hh:mm:ss").parse(widget.data?.createdAt ?? '').millisecondsSinceEpoch, context, fullCaption: true)
                              : '',
                          textStyle: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                  isAnnouncement ? const SizedBox.shrink() : (isLoading ? const CircularProgressIndicator() : widget.rightWidget)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
