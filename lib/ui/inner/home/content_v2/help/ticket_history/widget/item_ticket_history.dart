import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

import '../../../../../../../core/arguments/detail_ticket_argument.dart';
import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/enum.dart';
import '../../../../../../../core/models/collection/support_ticket/ticket_model.dart';

class ItemTicketHistory extends StatelessWidget {
  TicketModel data;
  LocalizationModelV2 model;
  bool isFirst;
  ItemTicketHistory({Key? key, required this.data, required this.model, required this.isFirst}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ItemTicketHistory');
    final isDarkMode = context.isDarkMode();
    final fixDate = data.dateTime?.split('T')[0];
    return GestureDetector(
      onTap: (){
        Routing().move(Routes.detailTAHistory, argument: DetailTicketArgument(ticketModel: data));
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
            _getTypeBadge(context, data.type ?? TicketType.content, data.statusEnum ?? TicketStatus.notSolved, model),
            Container(
              width: double.infinity,
              height: 1,
              color: kHyppeBorder,
            ),
            sixteenPx,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(textToDisplay: '${model.ticket}: ${data.ticketNo}', textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 12),),
                    sixPx,
                    CustomTextWidget(textToDisplay: 'Level: ${data.levelName ?? data.levelTicket}', textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 10, color: isDarkMode ? Colors.white: kHyppeLightSecondary),)
                  ],
                ),
                if(fixDate != null)
                  CustomTextWidget(textToDisplay: fixDate.getDateFormat("yyyy-MM-dd", model), textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 8, color: isDarkMode ? Colors.white: kHyppeLightSecondary))
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget _getTypeBadge(BuildContext context, TicketType type, TicketStatus status, LocalizationModelV2 model){
  var resIcon = '';
  var labelBadge = '';
  switch(type){
    case TicketType.content:
      resIcon = "${AssetPath.vectorPath}content_icon.svg";
      labelBadge = model.content ?? 'Content';
      break;
    case TicketType.ads:
      resIcon = "${AssetPath.vectorPath}ads_icon.svg";
      labelBadge = model.ads ?? 'Ads';
      break;
    case TicketType.accountVerification:
      resIcon = "${AssetPath.vectorPath}verified_user_icon.svg";
      labelBadge = model.accountVerification ?? '';
      break;
    case TicketType.owner:
      resIcon = "${AssetPath.vectorPath}ownership_icon.svg";
      labelBadge = model.ownership ?? 'Ownership';
      break;
    case TicketType.transaction:
      resIcon = "${AssetPath.vectorPath}purse_icon.svg";
      labelBadge = model.transaction ?? 'Transaction';
      break;
    case TicketType.problemBugs:
      resIcon = "${AssetPath.vectorPath}technical_issue_icon.svg";
      labelBadge = model.problemBugs ?? 'Technical Problems';
      break;
    default:
      resIcon = "${AssetPath.vectorPath}content_icon.svg";
      labelBadge = model.content ?? 'Content';
      break;
  }

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

  return SizedBox(
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            CustomIconWidget(iconData: resIcon),
            Container(
              margin: const EdgeInsets.only(left: 8, top: 14, bottom: 13),
              child: CustomTextWidget(textToDisplay: labelBadge, textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 12),),
            ),
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
