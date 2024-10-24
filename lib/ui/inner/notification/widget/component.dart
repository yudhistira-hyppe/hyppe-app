import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/view_streaming_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/link_stream_model.dart';
import 'package:hyppe/core/models/collection/notification_v2/notification.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction_coin_detail/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/appeal/pelanggaran_detail.dart';
import 'package:hyppe/ui/inner/notification/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/services/dynamic_link_service.dart';
import '../../../constant/widget/custom_icon_widget.dart';

class Component extends StatefulWidget {
  final Widget rightWidget;
  final NotificationModel? data;

  const Component({Key? key, required this.rightWidget, this.data})
      : super(key: key);

  @override
  State<Component> createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Component');
    SizeConfig().init(context);
    final isAnnouncement = widget.data?.actionButtons != null &&
        widget.data?.eventType == 'GENERAL';
    return InkWell(
      onTap: () async {
        print(isLoading);
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
                  if (fixUrl.contains('https://share.hyppe.app/')) {
                    final uri = Uri.parse(fixUrl);
                    final data =
                        await FirebaseDynamicLinks.instance.getDynamicLink(uri);
                    DynamicLinkService.handleDeepLink(data);
                  } else {
                    final uri = Uri.parse(fixUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      throw "Could not launch $uri";
                    }
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
            context
                .read<NotificationNotifier>()
                .markAsRead(context, widget.data ?? NotificationModel());
            final eventType =
                System().getNotificationCategory(widget.data?.eventType ?? '');
            var listTransacation = [
              NotificationCategory.transactions,
              NotificationCategory.adsClick,
              NotificationCategory.adsView,
            ];
            if (NotificationCategory.coin ==
                System().getNotificationCategory(widget.data?.event ?? '')) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionCoinDetailScreen(
                            invoiceid: widget.data?.postID ?? '',
                            title: 'Detail Transaksi',
                          )));
              // Routing().move(Routes.paymentsuccessdetail, argument: {'postId': widget.data?.postID??'', 'type':'Notification'});
            } else if (listTransacation.contains(eventType)) {
              await Routing().move(Routes.saldoCoins);
            } else if (NotificationCategory.challange == eventType) {
              await Routing().move(Routes.chalengeDetail,
                  argument: GeneralArgument()
                    ..id = widget.data?.postID
                    ..index = widget.data?.contentEventID != null ? 1 : 0
                    ..isTrue =
                        widget.data?.actionButtons == "true" ? true : false
                    ..title = widget.data?.title
                    ..body = System().bodyMultiLang(
                            bodyEn: widget.data?.body ?? widget.data?.bodyId,
                            bodyId: widget.data?.bodyId) ??
                        ''
                    ..session = widget.data?.contentEventID == null
                        ? null
                        : int.parse(widget.data?.contentEventID ?? '0'));
            } else if ("LIVE" == widget.data?.event) {
              Routing().move(Routes.viewStreaming,
                  argument: ViewStreamingArgument(
                      data: LinkStreamModel(sId: widget.data?.streamId)));
            } else if ("LIVE_GIFT" == widget.data?.event) {
              Routing().move(Routes.saldoCoins);
            } else if ("LIVE_BENNED" == widget.data?.event) {
              print("==== id ${widget.data?.dataBanned?.first.idBanned}");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PelanggaranDetail(
                      idBanned: widget.data?.dataBanned?.first.idBanned ?? ''),
                ),
              );
            } else {
              if (widget.data?.eventType == 'FOLLOWER') {
                System().navigateToProfile(context, widget.data?.mate ?? '');
              } else {
                await context.read<NotificationNotifier>().navigateToContent(
                    context, widget.data?.postType, widget.data?.postID);
              }
            }
          }
          setState(() {
            isLoading = false;
          });
        }

        // if (widget.data?.eventType == '')
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // profile picture
            widget.data?.eventType == 'CHALLENGE' ||
                    widget.data?.eventType == 'NOTIFY_LIVE' ||
                    System().convertEventType(widget.data?.eventType) ==
                        InteractiveEventType.kyc
                ? Container(
                    padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                    ),
                    child: CustomIconWidget(
                      width: 30 * SizeConfig.scaleDiagonal,
                      height: 30 * SizeConfig.scaleDiagonal,
                      iconData:
                          "${AssetPath.vectorPath}notification-active.svg",
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
                          onTap: () {
                            print(
                                'ini data widget data ${widget.data?.toJson()}');
                            System().navigateToProfile(
                                context, widget.data?.mate ?? '');
                          },
                          imageUrl:
                              '${System().showUserPicture(widget.data?.senderOrReceiverInfo?.avatar?.mediaEndpoint)}',
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
                              : widget.data?.eventType == 'NOTIFY_LIVE'
                                  ? (System().bodyMultiLang(
                                          bodyEn: widget.data?.title ??
                                              widget.data?.title,
                                          bodyId: widget.data?.titleId) ??
                                      '')
                                  : isAnnouncement
                                      ? (System().bodyMultiLang(
                                              bodyEn: widget.data?.titleEN ??
                                                  widget.data?.title,
                                              bodyId: widget.data?.title) ??
                                          '')
                                      : widget.data?.senderOrReceiverInfo
                                              ?.username ??
                                          '',
                          textAlign: TextAlign.start,
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
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
                            textToDisplay: System().bodyMultiLang(
                                    bodyEn: widget.data?.body ??
                                        widget.data?.bodyId,
                                    bodyId: widget.data?.bodyId) ??
                                '',
                            textStyle: Theme.of(context).textTheme.bodySmall,
                            maxLines: 4,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        sixPx,
                        CustomTextWidget(
                          textToDisplay: widget.data?.createdAt != null
                              ? System().readTimestamp(
                                  DateFormat("yyyy-MM-dd HH:mm:ss")
                                      .parse(widget.data?.createdAt ?? '')
                                      .millisecondsSinceEpoch,
                                  context,
                                  fullCaption: true)
                              : '',
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                  isAnnouncement
                      ? const SizedBox.shrink()
                      : (isLoading
                          ? const CircularProgressIndicator()
                          : widget.rightWidget)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
