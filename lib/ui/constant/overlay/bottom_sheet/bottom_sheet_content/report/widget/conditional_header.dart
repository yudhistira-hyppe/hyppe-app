import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content/profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';

Widget conditionalHeader(context) {
  SizeConfig().init(context);
  final notifier = Provider.of<ReportNotifier>(context);
  if (notifier.reportType == ReportType.post && notifier.reportAction == ReportAction.report) {
    return const SizedBox.shrink();
  }

  if (notifier.reportType == ReportType.post && notifier.reportAction == ReportAction.hide) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => ListTile(
        title: CustomTextWidget(
          textToDisplay: notifier.translate.tellUsWhyYouDontWantToSeeThis!,
          textStyle: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.start,
          textOverflow: TextOverflow.clip,
        ),
        subtitle: CustomTextWidget(
          textToDisplay: notifier.translate.yourFeedbackWillHelpUsToImproveYourExperience!,
          textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeSecondary),
          textAlign: TextAlign.start,
          textOverflow: TextOverflow.clip,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  if (notifier.reportType == ReportType.profile && notifier.reportAction == ReportAction.block) {
    // return Consumer<ProfileNotifier>(
    //   builder: (_, notifier, __) => Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       CustomTextWidget(
    //         textToDisplay: "${notifier.language.blockSubject} ${notifier.peopleProfile!.profileOverviewData!.userOverviewData.username!}?",
    //         textStyle: Theme.of(context).textTheme.subtitle1,
    //       ),
    //       twentyPx,
    //       SizedBox(
    //         width: SizeConfig.screenWidth! * 0.9,
    //         child: CustomTextWidget(
    //             textAlign: TextAlign.left,
    //             textOverflow: TextOverflow.visible,
    //             textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: kHyppeSecondary),
    //             textToDisplay: notifier.language.blockBody!),
    //       ),
    //     ],
    //   ),
    // );
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            textToDisplay: "${notifier.translate.blockSubject} dummy_user?",
            textStyle: Theme.of(context).textTheme.subtitle1,
          ),
          twentyPx,
          SizedBox(
            width: SizeConfig.screenWidth! * 0.9,
            child: CustomTextWidget(
                textAlign: TextAlign.left,
                textOverflow: TextOverflow.visible,
                textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: kHyppeSecondary),
                textToDisplay: notifier.translate.blockBody ?? ''),
          ),
        ],
      ),
    );
  }

  if (notifier.reportType == ReportType.profile && notifier.reportAction == ReportAction.report) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: SizeConfig.screenWidth! * 0.9,
          child: CustomTextWidget(
              textAlign: TextAlign.left,
              textOverflow: TextOverflow.clip,
              textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: kHyppeSecondary),
              textToDisplay: notifier.translate.reportToContentOnThisProfileOrThatThisAccount!),
        ),
        twentyPx,
        SizedBox(
            width: SizeConfig.screenWidth! * 0.9,
            child: CustomTextWidget(
                textAlign: TextAlign.left,
                textOverflow: TextOverflow.clip,
                textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: kHyppeSecondary),
                textToDisplay: notifier.translate.noteToReportActivityByThisMemberGoToTheSpecific!)),
        twentyPx,
        CustomTextWidget(textToDisplay: notifier.translate.tellUsALittleMore!, textStyle: Theme.of(context).textTheme.subtitle1)
      ]),
    );
  }

  return const SizedBox.shrink();
}
