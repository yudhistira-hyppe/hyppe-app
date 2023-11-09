import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/detail_ticket_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/support_ticket/ticket_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/detail_ticket/widget/show_images.dart';
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../core/models/collection/utils/ticket/ticket_url.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../../../constant/widget/custom_text_widget.dart';
import '../../../../../constant/widget/icon_button_widget.dart';
import '../../../../notification/notifier.dart';
import 'notifier.dart';

class DetailTicketScreen extends StatefulWidget {
  final DetailTicketArgument data;

  const DetailTicketScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailTicketScreen> createState() => _DetailTicketScreenState();
}

class _DetailTicketScreenState extends State<DetailTicketScreen> with AfterFirstLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.data.ticketModel != null) {
      context.read<DetailTicketNotifier>().getDetailTicket(context);
    }
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'DetailTicketScreen');
    if (widget.data.ticketModel != null) {
      context.read<DetailTicketNotifier>().initStateDetailTicket(widget.data.ticketModel!);
    } else {
      context.read<DetailTicketNotifier>().disposeState();
    }
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      context.read<DetailTicketNotifier>().disposeState();
    } catch (e) {
      e.logger();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAppeal = widget.data.appealModel;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<DetailTicketNotifier>(
      builder: (context, notifier, _) {
        final dataTicket = notifier.ticketModel;
        if (dataTicket != null) {
          return Scaffold(
            appBar: AppBar(
              leading: CustomIconButtonWidget(
                defaultColor: true,
                iconData: "${AssetPath.vectorPath}back-arrow.svg",
                onPressed: () => Routing().moveBack(),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  CustomTextWidget(
                    textToDisplay: dataTicket.ticketNo ?? 'Ticket History',
                    textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
                  ),
                  eightPx,
                  _getBadgeTicket(dataTicket.statusEnum ?? TicketStatus.notSolved, notifier.language)
                ],
              ),
              centerTitle: false,
            ),
            body: dataTicket.detail == null
                ? _getShimmerDetail(context)
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          strokeWidth: 2.0,
                          color: Colors.purple,
                          onRefresh: () => notifier.getDetailTicket(context, isRefresh: true),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 12),
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    color: kHyppeLightSurface,
                                  ),
                                  child: Column(
                                    children: [
                                      _contentInfo(textTheme, title: notifier.language.ticket ?? 'Ticket', value: dataTicket.ticketNo ?? ''),
                                      _contentInfo(textTheme, title: notifier.language.source ?? 'Source', value: dataTicket.sourceName ?? ''),
                                      if (dataTicket.dateTime != null)
                                        Builder(
                                          builder: (context) {
                                            try {
                                              var fixSplitDateTime = dataTicket.dateTime?.split('T');
                                              var fixSplitTime = fixSplitDateTime?[1].split(':');
                                              return _contentInfo(textTheme,
                                                  title: notifier.language.submissionTime ?? 'Submission Time',
                                                  value:
                                                      '${fixSplitDateTime?[0].getDateFormat("yyyy-MM-dd", notifier.language, isToday: true)} ${System().getTimeWIB(fixSplitTime?[0] ?? '00', fixSplitTime?[1] ?? '00')}');
                                            } catch (e) {
                                              'Error Builder Date fix : $e'.logger();
                                              return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                      _contentInfo(textTheme, title: notifier.language.operationSystem ?? 'Operation System', value: dataTicket.os ?? (notifier.language.notDefined ?? 'Not Defined')),
                                      _contentInfo(textTheme, title: notifier.language.category ?? 'Category', value: dataTicket.category ?? ''),
                                      _contentInfo(textTheme, title: notifier.language.level ?? 'Level', value: dataTicket.levelName ?? ''),
                                      _contentInfo(textTheme, title: notifier.language.description ?? 'Description', value: dataTicket.body ?? ''),
                                      _contentInfo(textTheme, title: notifier.language.attachment ?? 'Attachment', value: '${dataTicket.fsSourceUri?.length ?? '0'}')
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(left: 13, right: 10, top: 10, bottom: 10),
                                  margin: const EdgeInsets.only(left: 16, right: 16),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                    color: kHyppeLightSurface,
                                  ),
                                  child: Row(
                                    children: [
                                      const CustomIconWidget(
                                        iconData: '${AssetPath.vectorPath}info-icon.svg',
                                        defaultColor: false,
                                        color: kHyppeLightSecondary,
                                      ),
                                      twelvePx,
                                      CustomTextWidget(
                                        textToDisplay: notifier.language.messageTicketHandled ?? '',
                                        textStyle: const TextStyle(fontWeight: FontWeight.w400, color: kHyppeLightSecondary, fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                sixteenPx,
                                _getListChats(context, dataTicket.detail, notifier),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // CommentTextField(fromFront: false)
                      _buildTextInput(context, notifier)
                    ],
                  ),
          );
        } else if (dataAppeal != null) {
          return Scaffold(
            appBar: AppBar(
              leading: CustomIconButtonWidget(
                defaultColor: true,
                iconData: "${AssetPath.vectorPath}back-arrow.svg",
                onPressed: () => Routing().moveBack(),
              ),
              titleSpacing: 0,
              title: Row(
                children: [
                  CustomTextWidget(
                    textToDisplay: notifier.language.contentAppeal ?? 'Content Appeal',
                    textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
                  ),
                  eightPx,
                  _getBadgeAppeal(dataAppeal.status ?? AppealStatus.removed, notifier.language)
                ],
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 12),
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: kHyppeLightSurface,
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12, top: 5),
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Builder(builder: (context) {
                                      var thumbnail = '';
                                      final imageInfo = dataAppeal.media?.imageInfo;
                                      final videoInfo = dataAppeal.media?.videoInfo;

                                      String? urlImage;
                                      String? urlVideo;
                                      if (imageInfo != null) {
                                        if (imageInfo.isNotEmpty) {
                                          urlImage = dataAppeal.media?.imageInfo?.first.url;
                                        }
                                      } else if (videoInfo != null) {
                                        if (videoInfo.isNotEmpty) {
                                          urlVideo = dataAppeal.media?.videoInfo?.first.coverURL;
                                        }
                                      }
                                      if (urlImage != null) {
                                        thumbnail = urlImage;
                                      } else if (urlVideo != null) {
                                        thumbnail = urlVideo;
                                      } else {
                                        thumbnail = System().showUserPicture(dataAppeal.mediaThumbEndPoint) ?? '';
                                      }
                                      return CustomContentModeratedWidget(
                                        width: 40,
                                        height: 40,
                                        isSale: false,
                                        isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                        thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: thumbnail),
                                      );
                                    }),
                                    tenPx,
                                    CustomTextWidget(
                                      textToDisplay: dataAppeal.description ?? '',
                                      maxLines: 3,
                                      textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (dataAppeal.status != AppealStatus.newest)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    height: 80,
                                    width: context.getWidth() * 0.3,
                                    alignment: Alignment.bottomRight,
                                    child: InkWell(
                                      onTap: () async {
                                        notifier.isLoadNavigate = true;
                                        Future.delayed(const Duration(seconds: 1), () {
                                          notifier.isLoadNavigate = false;
                                        });
                                        await context.read<NotificationNotifier>().navigateToContent(context, dataAppeal.postType, dataAppeal.postID);
                                      },
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          CustomTextWidget(
                                            textAlign: TextAlign.end,
                                            textToDisplay: notifier.language.seeContent ?? '',
                                            textStyle: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontSize: 10),
                                          ),
                                          if (notifier.isLoadNavigate) fourPx,
                                          if (notifier.isLoadNavigate)
                                            const SizedBox(
                                                width: 10,
                                                height: 10,
                                                child: CircularProgressIndicator(
                                                  color: kHyppePrimary,
                                                  strokeWidth: 1,
                                                ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                          child: SizedBox(
                            height: 1,
                            child: Container(color: Colors.black12),
                          ),
                        ),
                        _contentInfo(textTheme, title: 'Post ID', value: dataAppeal.postID ?? ''),
                        if (dataAppeal.createdAt != null)
                          Builder(
                            builder: (context) {
                              try {
                                var fixSplitDateTime = dataAppeal.createdAt?.split(' ');
                                var fixSplitTime = fixSplitDateTime?[1].split(':');
                                return _contentInfo(textTheme,
                                    title: notifier.language.postedOn ?? 'Posted On',
                                    value:
                                        '${fixSplitDateTime?[0].getDateFormat("yyyy-MM-dd", notifier.language, isToday: false)} ${System().getTimeWIB(fixSplitTime?[0] ?? '00', fixSplitTime?[1] ?? '00')}');
                              } catch (e) {
                                'Error Builder Date fix : $e'.logger();
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        if (dataAppeal.createdAtAppealLast != null)
                          Builder(builder: (context) {
                            try {
                              var fixSplitDateTime = dataAppeal.createdAt?.split('T');
                              var fixSplitTime = fixSplitDateTime?[1].split(':');
                              return _contentInfo(textTheme,
                                  title: notifier.language.submissionTime ?? 'Submission Time',
                                  value:
                                      '${fixSplitDateTime?[0].getDateFormat("yyyy-MM-dd", notifier.language, isToday: false)} ${System().getTimeWIB(fixSplitTime?[0] ?? '00', fixSplitTime?[1] ?? '00')}');
                            } catch (e) {
                              'Error Builder Date fix : $e'.logger();
                              return const SizedBox.shrink();
                            }
                          }),
                        _contentInfo(textTheme, title: notifier.language.contentType ?? 'Content Type', value: System().convertTypeContent(dataAppeal.postType ?? '')),
                        _contentInfo(textTheme, title: notifier.language.sensitiveType ?? 'Sensitive Type', value: dataAppeal.reportedStatus ?? ''),
                        Builder(builder: (context) {
                          try {
                            final item = dataAppeal.reportedUser?.where((element) => element.active == true).toList();
                            if (item != null) {
                              if (item.isNotEmpty) {
                                return _contentInfo(textTheme, title: notifier.language.reasonOfAppeal ?? 'Reason of Appeal', value: item.first.description ?? '');
                              } else {
                                return _contentInfo(textTheme, title: notifier.language.reasonOfAppeal ?? 'Reason of Appeal', value: dataAppeal.reasonLast ?? '');
                              }
                            } else {
                              return _contentInfo(textTheme, title: notifier.language.reasonOfAppeal ?? 'Reason of Appeal', value: dataAppeal.reasonLast ?? '');
                            }
                          } catch (e) {
                            return const SizedBox.shrink();
                          }
                        }),
                        _contentInfo(textTheme, title: notifier.language.issueStatement ?? 'Issue Statement', value: dataAppeal.reportedUserHandle?.first.reason ?? ''),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 13, right: 10, top: 10, bottom: 10),
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: kHyppeLightSurface,
                    ),
                    child: Row(
                      children: [
                        const CustomIconWidget(
                          iconData: '${AssetPath.vectorPath}info-icon.svg',
                          defaultColor: false,
                          color: kHyppeLightSecondary,
                        ),
                        twelvePx,
                        CustomTextWidget(
                          textToDisplay: notifier.language.messageTicketHandled ?? '',
                          textStyle: const TextStyle(fontWeight: FontWeight.w400, color: kHyppeLightSecondary, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _getBadgeAppeal(AppealStatus status, LocalizationModelV2 model) {
    var labelProgress = '';
    var colorFont = Colors.transparent;
    var colorBg = Colors.transparent;
    switch (status) {
      case AppealStatus.notSuspended:
        labelProgress = model.notSuspend ?? 'Not Suspend';
        colorFont = kHyppeFontInprogress;
        colorBg = kHyppeBgInprogress;
        break;
      case AppealStatus.newest:
        labelProgress = model.newLabel ?? 'New';
        colorFont = kHyppeFontNew;
        colorBg = kHyppeBgNew;
        break;
      case AppealStatus.suspend:
        labelProgress = model.suspend ?? 'Suspend';
        colorFont = kHyppeFontSolve;
        colorBg = kHyppeBgSolved;
        break;
      case AppealStatus.removed:
        labelProgress = model.remove ?? 'Not Solved';
        colorFont = kHyppeFontNotSolve;
        colorBg = kHyppeBgNotSolve;
        break;
      case AppealStatus.flaging:
        labelProgress = model.flagAsSensitive ?? 'Flag as Sensitive';
        colorFont = kHyppeBgSensitive;
        colorBg = kHyppeBgSensitive.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
      child: CustomTextWidget(
        textToDisplay: labelProgress,
        textStyle: TextStyle(color: colorFont, fontWeight: FontWeight.w700, fontSize: 10),
      ),
      decoration: BoxDecoration(color: colorBg, borderRadius: const BorderRadius.all(Radius.circular(4))),
    );
  }

  Widget _getBadgeTicket(TicketStatus status, LocalizationModelV2 model) {
    var labelProgress = '';
    var colorFont = Colors.transparent;
    var colorBg = Colors.transparent;
    switch (status) {
      case TicketStatus.inProgress:
        labelProgress = model.inProgress ?? 'In-Progress';
        colorFont = kHyppeFontInprogress;
        colorBg = kHyppeBgInprogress;
        break;
      case TicketStatus.newest:
        labelProgress = model.newLabel ?? 'New';
        colorFont = kHyppeFontNew;
        colorBg = kHyppeBgNew;
        break;
      case TicketStatus.solved:
        labelProgress = model.solved ?? 'Solved';
        colorFont = kHyppeFontSolve;
        colorBg = kHyppeBgSolved;
        break;
      case TicketStatus.notSolved:
        labelProgress = model.notSolved ?? 'Not Solved';
        colorFont = kHyppeFontNotSolve;
        colorBg = kHyppeBgNotSolve;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
      child: CustomTextWidget(
        textToDisplay: labelProgress,
        textStyle: TextStyle(color: colorFont, fontWeight: FontWeight.w700, fontSize: 10),
      ),
      decoration: BoxDecoration(color: colorBg, borderRadius: const BorderRadius.all(Radius.circular(4))),
    );
  }

  Widget _contentInfo(TextTheme textTheme, {required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CustomTextWidget(
              textAlign: TextAlign.left,
              textToDisplay: title,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(
            child: CustomTextWidget(
              textAlign: TextAlign.right,
              maxLines: 3,
              textToDisplay: value,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getListChats(BuildContext context, List<TicketDetail>? chats, DetailTicketNotifier notifier) {
    Map<String, List<TicketDetail>?> groupChats = {};

    // final email = SharedPreference().readStorage(SpKeys.email);
    if (chats != null) {
      if (chats.isNotEmpty) {
        for (var chat in chats) {
          final chatDate = chat.datetime?.split('T')[0];
          if (chatDate != null) {
            if (groupChats[chatDate] != null) {
              groupChats[chatDate]?.add(chat);
            } else {
              groupChats[chatDate] = [];
              groupChats[chatDate]?.add(chat);
            }
          }
        }
        return _groupChatsLayout(context, groupChats, notifier);
        // return Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.only(left: 16, right: 16),
        //   child: Column(children: chats.map((e){
        //     if(email == e.email){
        //       return _senderLayout(context, e);
        //     }else{
        //       return _receiveLayout(context, e);
        //     }
        //   }).toList(),),
        // );
      } else {
        return SizedBox(
            height: 300,
            child: Center(
              child: CustomTextWidget(textToDisplay: notifier.language.dontHaveMessagesYet ?? "Don't have messages yet"),
            ));
      }
    } else {
      return SizedBox(
          height: 300,
          child: Center(
            child: CustomTextWidget(textToDisplay: notifier.language.dontHaveMessagesYet ?? "Don't have messages yet"),
          ));
    }
  }

  Widget _groupChatsLayout(BuildContext context, Map<String, List<TicketDetail>?> groupChats, DetailTicketNotifier notifier) {
    final List<Widget> groups = [];
    final email = SharedPreference().readStorage(SpKeys.email);
    groupChats.forEach((key, value) {
      if (value != null) {
        groups.add(Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 1,
                          child: Container(color: Colors.black12),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: kHyppeSecondary), borderRadius: const BorderRadius.all(Radius.circular(8)), color: kHyppeLightInactive1),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: CustomTextWidget(textToDisplay: key.getDateFormat("yyyy-MM-dd", notifier.language, isToday: true)),
                      ),
                    )
                  ],
                ),
              ),
              sixteenPx,
              Builder(builder: (context) {
                List<Widget> listChats = [];
                listChats.add(Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: value.map((e) {
                      if (email == e.email) {
                        return _senderLayout(context, e);
                      } else {
                        return _receiveLayout(context, e);
                      }
                    }).toList(),
                  ),
                ));
                return Column(
                  children: listChats,
                );
              })
            ],
          ),
        ));
      }
    });
    return Column(
      children: groups,
    );
  }

  Widget _receiveLayout(BuildContext context, TicketDetail chatData) {
    SizeConfig().init(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: kHyppeBgReceiver,
              borderRadius: BorderRadius.only(
                topLeft: Radius.zero,
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: SizeConfig.screenWidth! * 0.65,
            ),
            child: Padding(
              padding: EdgeInsets.all(10 * SizeConfig.scaleDiagonal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (chatData.fsTargetUri?.isNotEmpty ?? false)
                    Builder(builder: (context) {
                      return _getGridListImages(context, chatData.ticketUrls);
                    }),
                  if (chatData.fsTargetUri?.isNotEmpty ?? false) tenPx,
                  CustomTextWidget(
                    // textToDisplay: chatData.message,
                    textAlign: TextAlign.start,
                    textOverflow: TextOverflow.clip,
                    textStyle: Theme.of(context).textTheme.bodyText2,
                    textToDisplay: chatData.body ?? 'No Message',
                  ),
                  Builder(builder: (context) {
                    final times = chatData.datetime?.split('T')[1].split(':');
                    return CustomTextWidget(
                      textAlign: TextAlign.end,
                      textToDisplay: times != null
                          ? times.isNotEmpty
                              ? '${times[0]}:${times[1]}'
                              : ''
                          : '',
                      textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontSize: 10),
                    );
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _senderLayout(BuildContext context, TicketDetail chatData) {
    SizeConfig().init(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: kHyppeBgSender,
              borderRadius: BorderRadius.only(
                topRight: Radius.zero,
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: SizeConfig.screenWidth! * 0.65,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (chatData.fsTargetUri?.isNotEmpty ?? false)
                    Builder(builder: (context) {
                      return _getGridListImages(context, chatData.ticketUrls);
                    }),
                  if (chatData.fsTargetUri?.isNotEmpty ?? false) tenPx,
                  CustomTextWidget(
                    // textToDisplay: chatData.message,
                    textAlign: TextAlign.start,
                    textOverflow: TextOverflow.clip,
                    textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white),
                    textToDisplay: chatData.body ?? 'No Messages',
                  ),
                  Builder(builder: (context) {
                    final times = chatData.datetime?.split('T')[1].split(':');
                    return CustomTextWidget(
                      textAlign: TextAlign.end,
                      textToDisplay: times != null
                          ? times.isNotEmpty
                              ? '${times[0]}:${times[1]}'
                              : ''
                          : '',
                      textStyle: const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getGridListImages(BuildContext context, List<TicketUrl> urls) {
    final fixList = urls.where((element) {
      '_getGridListImages : ${extensionFromMime(element.localDir)}'.logger();
      return System().lookupContentMimeType(element.localDir)?.contains('image') ?? false;
    }).toList();
    final lenght = fixList.length;
    final List<String> images = [];
    for (var element in fixList) {
      images.add(element.realUrl);
    }
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return ShowImages(imageUrls: images);
            },
            barrierColor: Colors.transparent);
      },
      child: Column(
        children: [
          // SelectableText('${fixList[0].realUrl}'),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Builder(builder: (context) {
              if (lenght == 1) {
                return CustomContentModeratedWidget(
                  width: 200,
                  height: 200,
                  isSale: false,
                  isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                  thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[0].realUrl),
                );
              } else if (lenght == 2) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      child: CustomContentModeratedWidget(
                        width: 100,
                        height: 100,
                        isSale: false,
                        isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                        thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[0].realUrl),
                      ),
                    ),
                    tenPx,
                    Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      child: CustomContentModeratedWidget(
                        width: 100,
                        height: 100,
                        isSale: false,
                        isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                        thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[1].realUrl),
                      ),
                    ),
                  ],
                );
              } else if (lenght == 3) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[0].realUrl),
                          ),
                        ),
                        tenPx,
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[1].realUrl),
                          ),
                        ),
                      ],
                    ),
                    tenPx,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[2].realUrl),
                          ),
                        ),
                        tenPx,
                        Container(
                          width: 100,
                          height: 100,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ],
                );
              } else if (lenght == 4) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[0].realUrl),
                          ),
                        ),
                        tenPx,
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[1].realUrl),
                          ),
                        ),
                      ],
                    ),
                    tenPx,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[2].realUrl),
                          ),
                        ),
                        tenPx,
                        Container(
                          width: 100,
                          height: 100,
                          alignment: Alignment.center,
                          child: CustomContentModeratedWidget(
                            width: 100,
                            height: 100,
                            isSale: false,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: ImageUrl(widget.data.ticketModel?.idUser, url: fixList[3].realUrl),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context, DetailTicketNotifier notifier) {
    return Container(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((notifier.files ?? []).isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: notifier.files?.map((e) {
                          final isImage = System().lookupContentMimeType(e.path)?.startsWith('image') ?? false;
                          return Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(left: 5, right: 5, top: 16),
                                padding: EdgeInsets.all(isImage ? 0 : 16),
                                decoration:
                                    BoxDecoration(color: kHyppeBgSensitive.withOpacity(0.4), borderRadius: const BorderRadius.all(Radius.circular(8)), border: Border.all(color: kHyppeLightSecondary)),
                                child: isImage
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  child: Image.file(
                                    e,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),

                                )
                                    : Text('${e.path.split('/').last}'),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                      onTap: () {
                                        final index = notifier.files?.indexOf(e);
                                        if (index != null) {
                                          notifier.removeFiles(index);
                                        }
                                      },
                                      child: const CustomIconWidget(
                                        iconData: '${AssetPath.vectorPath}remove.svg',
                                        defaultColor: false,
                                        color: Colors.red,
                                      )))
                            ],
                          );
                        }).toList() ??
                        [],
                  ),
                  GestureDetector(
                    onTap: () {
                      notifier.removeAllFiles();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Colors.red),
                      child: const CustomIconWidget(
                        width: 50,
                        height: 50,
                        defaultColor: false,
                        color: Colors.white,
                        iconData: '${AssetPath.vectorPath}close.svg',
                      ),
                    ),
                  )
                ],
              ),
            ),
          if ((notifier.files ?? []).isNotEmpty) twelvePx,
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: TextFormField(
              minLines: 1,
              maxLines: 7,
              focusNode: notifier.inputNode,
              keyboardType: TextInputType.text,
              keyboardAppearance: Brightness.dark,
              controller: notifier.commentController,
              textInputAction: TextInputAction.unspecified,
              style: Theme.of(context).textTheme.bodyText2,
              autofocus: true,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.background,
                  hintText: "${notifier.language.typeAMessage}...",
                  hintStyle: const TextStyle(color: Color(0xffBABABA), fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          onTap: () {
                            notifier.onTapOnFrameLocalMedia(context);
                          },
                          child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}galery_icon.svg")),
                      notifier.commentController.text.isNotEmpty ? tenPx : twelvePx,
                      if (notifier.commentController.text.isNotEmpty)
                        GestureDetector(
                            onTap: () async {
                              notifier.inputNode.unfocus();
                              await notifier.sendComment(context, notifier.commentController.text);
                            },
                            child: const CustomIconWidget(
                              height: 24,
                              width: 24,
                              iconData: "${AssetPath.vectorPath}logo-purple.svg",
                              defaultColor: false,
                              color: kHyppePrimary,
                            )),
                      if (notifier.commentController.text.isNotEmpty) tenPx
                    ],
                  )),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getShimmerDetail(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 12),
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: kHyppeLightSurface,
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: Column(
                children: [
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                  _shimmerDetailTicket(),
                  eightPx,
                ],
              ),
            ),
          ),
          const CustomShimmer(
            width: double.infinity,
            padding: EdgeInsets.only(left: 13, right: 10, top: 10, bottom: 10),
            margin: EdgeInsets.only(left: 16, right: 16),
            radius: 8,
          ),
          tenPx,
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _shimmerSender(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerSender(context),
                eightPx,
                _shimmerSender(context),
                eightPx,
                _shimmerSender(context),
                eightPx,
                _shimmerSender(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerSender(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
                _shimmerSender(context),
                eightPx,
                _shimmerReceiver(context),
                eightPx,
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _shimmerDetailTicket() {
    var fixWidth = 6.0;
    final randomWidth = Random().nextInt(60).toDouble();
    if (randomWidth > fixWidth) {
      fixWidth = randomWidth;
    }
    return Row(
      children: [
        Expanded(
            child: CustomShimmer(
          radius: 8,
          height: 16,
        )),
        SizedBox(
          width: fixWidth,
        ),
        Expanded(
            child: CustomShimmer(
          radius: 8,
          height: 16,
        )),
      ],
    );
  }

  Widget _shimmerSender(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: CustomShimmer(
        radius: 8,
        width: context.getWidth() * 0.6,
        height: 20,
      ),
    );
  }

  Widget _shimmerReceiver(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: CustomShimmer(
        radius: 8,
        width: context.getWidth() * 0.6,
        height: 20,
      ),
    );
  }
}
