import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/support_ticket/appeal_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../../../../core/arguments/detail_ticket_argument.dart';
import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/localization_v2/localization_model.dart';
import '../../../../../../../ux/path.dart';
import '../../../../../../../ux/routing.dart';
import '../../../../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../../../../constant/widget/custom_spacer.dart';


class ItemContentAppeal extends StatelessWidget {
  final AppealModel data;
  LocalizationModelV2 model;
  bool isFirst;
  ItemContentAppeal({Key? key, required this.data, required this.model, required this.isFirst}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode();
    final fixDate = data.createdAt?.split(' ')[0];
    return GestureDetector(
      onTap: (){
        Routing().move(Routes.detailTAHistory, argument: DetailTicketArgument(appealModel: data));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 7, left: 16, right: 16, top: (isFirst ? 7 : 3)),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 9, bottom: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)],
          color: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          children: [
            _getHeaderAppeal(context, data.status ?? AppealStatus.removed, model),
            Container(
              width: double.infinity,
              height: 1,
              color: kHyppeBorder,
            ),
            sixteenPx,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    var thumbnail = '';
                    final imageInfo = data.media?.imageInfo;
                    final videoInfo = data.media?.videoInfo;

                    String? urlImage;
                    String? urlVideo;
                    if(imageInfo != null){
                      if(imageInfo.isNotEmpty){
                        urlImage = data.media?.imageInfo?.first.url;
                      }
                    }else if(videoInfo != null){
                      if(videoInfo.isNotEmpty){
                        urlVideo = data.media?.videoInfo?.first.coverURL;
                      }
                    }
                    if(urlImage != null){
                      thumbnail = urlImage;
                    }else if(urlVideo != null){
                      thumbnail = urlVideo;
                    }else{
                      thumbnail = System().showUserPicture(data.mediaEndPoint) ?? '';
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
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(textAlign: TextAlign.start,textToDisplay: 'Post ID: ${data.postID}', textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 12),),
                            sixPx,
                            CustomTextWidget(maxLines : 2, textToDisplay: data.description ?? data.reportedUser?[0].description ?? 'No Description', textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 10, color: isDarkMode ? Colors.white: kHyppeLightSecondary),)
                          ],
                        ),
                      ),
                      if(fixDate != null)
                        CustomTextWidget(textToDisplay: fixDate.getDateFormat("yyyy-MM-dd", model), textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 8, color: isDarkMode ? Colors.white: kHyppeLightSecondary))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _getHeaderAppeal(BuildContext context, AppealStatus status, LocalizationModelV2 model){

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

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 3, right: 10),
                child: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}hyppe_icon.svg",
                ),
              ),
              CustomTextWidget(
                  textToDisplay: System().convertTypeContent(data.postType ?? ''),
                  textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 12)
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 13),
            child: CustomTextWidget(textToDisplay: labelProgress, textStyle: TextStyle(color: colorFont, fontWeight: FontWeight.w700, fontSize: 10),),
            decoration: BoxDecoration(
                color: colorBg,
                borderRadius: const BorderRadius.all(Radius.circular(4))
            ),
          ),
        ],
      ),
    );
  }
}

