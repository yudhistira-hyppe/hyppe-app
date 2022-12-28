import 'dart:io';

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
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../../../constant/widget/custom_text_button.dart';
import '../../../../../constant/widget/custom_text_widget.dart';
import '../../../../../constant/widget/icon_button_widget.dart';
import 'notifier.dart';

class DetailTicketScreen extends StatefulWidget {
  DetailTicketArgument data;

  DetailTicketScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailTicketScreen> createState() => _DetailTicketScreenState();
}

class _DetailTicketScreenState extends State<DetailTicketScreen> with AfterFirstLayoutMixin{

  @override
  void afterFirstLayout(BuildContext context) {
    if(widget.data.ticketModel != null){
      context.read<DetailTicketNotifier>().getDetailTicket(context);
    }
  }


  @override
  void initState() {
    if(widget.data.ticketModel != null){
      context.read<DetailTicketNotifier>().initState(widget.data.ticketModel!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final dataAppeal = widget.data.appealModel;
    final textTheme = Theme.of(context).textTheme;
    return Consumer<DetailTicketNotifier>(builder: (context, notifier, _){
      final dataTicket = notifier.ticketModel;
      if(dataTicket != null){
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
                  textToDisplay: notifier.language.ticketHistory ?? 'Ticket History',
                  textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
                ),
                eightPx,
                _getBadgeTicket(dataTicket.statusEnum ?? TicketStatus.notSolved, notifier.language)
              ],
            ),
            centerTitle: false,
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 12),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: kHyppeLightSurface, ),
                        child: Column(
                          children: [
                            _contentInfo(textTheme, title: notifier.language.ticket ?? 'Ticket', value: dataTicket.ticketNo ?? ''),
                            _contentInfo(textTheme, title: notifier.language.source ?? 'Source', value: dataTicket.sourceName ?? ''),
                            if(dataTicket.dateTime != null)
                              Builder(builder: (context){
                                try{
                                  var fixSplitDateTime = dataTicket.dateTime?.split('T');
                                  var fixSplitTime = fixSplitDateTime?[1].split(':');
                                  return _contentInfo(textTheme, title: notifier.language.submissionTime ?? 'Submission Time', value: '${fixSplitDateTime?[0].getDateFormat("yyyy-MM-dd", notifier.language, isToday: false)} ${System().getTimeWIB(fixSplitTime?[0] ?? '00', fixSplitTime?[1] ?? '00') }');
                                }catch(e){
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
                          color: kHyppeLightSurface, ),
                        child: Row(
                          children: [
                            const CustomIconWidget(iconData: '${AssetPath.vectorPath}info-icon.svg', defaultColor: false, color: kHyppeLightSecondary,),
                            twelvePx,
                            CustomTextWidget(textToDisplay: notifier.language.messageTicketHandled ?? '', textStyle: const TextStyle(fontWeight: FontWeight.w400, color: kHyppeLightSecondary, fontSize: 12),)
                          ],
                        ),
                      ),
                      sixteenPx,
                      _getListChats(context, dataTicket.detail, notifier),
                    ],
                  ),
                ),
              ),
              // CommentTextField(fromFront: false)
              _buildTextInput(context, notifier)
            ],
          ),
        );
      }else if(dataAppeal != null){
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
                  textToDisplay: notifier.language.ticketHistory ?? 'Ticket History',
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
                    color: kHyppeLightSurface, ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12, top: 5),
                        child: Row(
                          children: [
                            Builder(
                                builder: (context) {
                                  var thumbnail = '';
                                  final imageInfo = dataAppeal.media?.imageInfo;
                                  final videoInfo = dataAppeal.media?.videoInfo;

                                  String? urlImage;
                                  String? urlVideo;
                                  if(imageInfo != null){
                                    if(imageInfo.isNotEmpty){
                                      urlImage = dataAppeal.media?.imageInfo?.first.url;
                                    }
                                  }else if(videoInfo != null){
                                    if(videoInfo.isNotEmpty){
                                      urlVideo = dataAppeal.media?.videoInfo?.first.coverURL;
                                    }
                                  }
                                  if(urlImage != null){
                                    thumbnail = urlImage;
                                  }else if(urlVideo != null){
                                    thumbnail = urlVideo;
                                  }else{
                                    thumbnail = System().showUserPicture(dataAppeal.mediaThumbEndPoint) ?? '';
                                  }
                                  return CustomContentModeratedWidget(
                                    width: 40,
                                    height: 40,
                                    isSale: false,
                                    isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                    thumbnail: thumbnail,
                                  );
                                }
                            ),
                            tenPx,
                            CustomTextWidget(textToDisplay: dataAppeal.description ?? '', maxLines: 3, textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),)
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
                      _contentInfo(textTheme, title: notifier.language.ticket ?? 'Ticket', value: dataAppeal.postID ?? ''),
                      if(dataAppeal.createdAt != null)
                        Builder(builder: (context){
                          try{
                            var fixSplitDateTime = dataAppeal.createdAt?.split(' ');
                            var fixSplitTime = fixSplitDateTime?[1].split(':');
                            return _contentInfo(textTheme, title: notifier.language.postedOn ?? 'Posted On', value: '${fixSplitDateTime?[0].getDateFormat("yyyy-MM-dd", notifier.language, isToday: false)} ${System().getTimeWIB(fixSplitTime?[0] ?? '00', fixSplitTime?[1] ?? '00') }');
                          }catch(e){
                            'Error Builder Date fix : $e'.logger();
                            return const SizedBox.shrink();
                          }
                        },
                        ),
                      if(dataAppeal.createdAtAppealLast != null)
                        Builder(builder: (context){
                          try{
                            var fixSplitDateTime = dataAppeal.createdAt?.split('T');
                            var fixSplitTime = fixSplitDateTime?[1].split(':');
                            return _contentInfo(textTheme, title: notifier.language.submissionTime ?? 'Submission Time', value: '${fixSplitDateTime?[0].getDateFormat("yyyy-MM-dd", notifier.language, isToday: false)} ${System().getTimeWIB(fixSplitTime?[0] ?? '00', fixSplitTime?[1] ?? '00') }');
                          }catch(e){
                            'Error Builder Date fix : $e'.logger();
                            return const SizedBox.shrink();
                          }
                        }),
                      _contentInfo(textTheme, title: notifier.language.contentType ?? 'Content Type', value: System().convertTypeContent(dataAppeal.postType ?? '')),
                      _contentInfo(textTheme, title: notifier.language.sensitiveType ?? 'Sensitive Type', value: dataAppeal.reportedStatus ?? ''),
                      Builder(builder: (context){
                        try{
                          final item = dataAppeal.reportedUser?.where((element) => element.active == true).toList();
                          if(item != null){
                            if(item.isNotEmpty){
                              return _contentInfo(textTheme, title: notifier.language.reasonOfAppeal ?? 'Reason of Appeal', value: item.first.description ?? '');
                            }else{
                              return _contentInfo(textTheme, title: notifier.language.reasonOfAppeal ?? 'Reason of Appeal', value: dataAppeal.reasonLast ?? '');
                            }

                          }else{
                            return _contentInfo(textTheme, title: notifier.language.reasonOfAppeal ?? 'Reason of Appeal', value: dataAppeal.reasonLast ?? '');
                          }

                        }catch(e){
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
                    color: kHyppeLightSurface, ),
                  child: Row(
                    children: [
                      const CustomIconWidget(iconData: '${AssetPath.vectorPath}info-icon.svg', defaultColor: false, color: kHyppeLightSecondary,),
                      twelvePx,
                      CustomTextWidget(textToDisplay: notifier.language.messageTicketHandled ?? '', textStyle: const TextStyle(fontWeight: FontWeight.w400, color: kHyppeLightSecondary, fontSize: 12),)
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }else{
        return Container();
      }

    }
    ,);
  }

  Widget _getBadgeAppeal(AppealStatus status, LocalizationModelV2 model){
    var labelProgress = '';
    var colorFont = Colors.transparent;
    var colorBg = Colors.transparent;
    switch(status){
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
      child: CustomTextWidget(textToDisplay: labelProgress, textStyle: TextStyle(color: colorFont, fontWeight: FontWeight.w700, fontSize: 10),),
      decoration: BoxDecoration(
          color: colorBg,
          borderRadius: const BorderRadius.all(Radius.circular(4))
      ),
    );
  }

  Widget _getBadgeTicket(TicketStatus status, LocalizationModelV2 model){
    var labelProgress = '';
    var colorFont = Colors.transparent;
    var colorBg = Colors.transparent;
    switch(status){
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
      child: CustomTextWidget(textToDisplay: labelProgress, textStyle: TextStyle(color: colorFont, fontWeight: FontWeight.w700, fontSize: 10),),
      decoration: BoxDecoration(
          color: colorBg,
          borderRadius: const BorderRadius.all(Radius.circular(4))
      ),
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

  Widget _getListChats(BuildContext context, List<TicketDetail>? chats, DetailTicketNotifier notifier){
    final email = SharedPreference().readStorage(SpKeys.email);
    if(chats != null){
      if(chats.isNotEmpty){
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(children: chats.map((e){
            if(email == e.email){
              return _senderLayout(context, e);
            }else{
              return _receiveLayout(context, e);
            }
          }).toList(),),
        );
      }else{
        return SizedBox(height: 300, child: Center(child: CustomTextWidget(textToDisplay: notifier.language.dontHaveMessagesYet ?? "Don't have messages yet"),));
      }
    }else{
      return SizedBox(height: 300, child: Center(child: CustomTextWidget(textToDisplay: notifier.language.dontHaveMessagesYet ?? "Don't have messages yet"),));
    }
  }

  Widget _receiveLayout(BuildContext context, TicketDetail chatData){
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
              maxWidth: SizeConfig.screenWidth! * 0.7,
            ),
            child: Padding(
              padding: EdgeInsets.all(10 * SizeConfig.scaleDiagonal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextWidget(
                    // textToDisplay: chatData.message,
                    textAlign: TextAlign.start,
                    textOverflow: TextOverflow.clip,
                    textStyle: Theme.of(context).textTheme.bodyText2,
                    textToDisplay: chatData.body ?? 'No Message',
                  ),
                  // CustomTextWidget(
                  //   textAlign: TextAlign.end,
                  //   textStyle: TextStyle(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 10),
                  //   textToDisplay: chatData.datetime == null ? "" : System().dateFormatter(chatData.datetime ?? '', 1),
                  //   // textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(created ?? '', 1),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _senderLayout(BuildContext context, TicketDetail chatData){
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
              maxWidth: SizeConfig.screenWidth! * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextWidget(
                    // textToDisplay: chatData.message,
                    textAlign: TextAlign.start,
                    textOverflow: TextOverflow.clip,
                    textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.black),
                    textToDisplay: chatData.body ?? 'No Messages',
                  ),
                  // CustomTextWidget(
                  //   textAlign: TextAlign.end,
                  //   textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(chatData?.createdAt ?? '', 1),
                  //   textStyle: TextStyle(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 10),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context, DetailTicketNotifier notifier) {
    return Container(
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
          fillColor: Theme.of(context).colorScheme.primary,
          hintText: "${notifier.language.typeAMessage}...",
          hintStyle: const TextStyle(color: Color(0xffBABABA), fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          suffixIcon: notifier.commentController.text.isNotEmpty
              ? CustomTextButton(
            child: CustomTextWidget(
              textToDisplay: notifier.language.send ?? '',
              textStyle: TextStyle(
                color: Theme.of(context).colorScheme.primaryVariant,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () async {
              notifier.inputNode.unfocus();
              await notifier.sendComment(context, notifier.commentController.text);
              // notifier.addComment(context);
            },
        ): SizedBox.shrink(),
      ),
        onChanged: (value){
          setState(() {

          });
        },
    ),
    );
  }

  
  

}