import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget conditionalBottom(context) {
  SizeConfig().init(context);
  final notifier = Provider.of<ReportNotifier>(context);
  if (notifier.reportType == ReportType.post &&
      notifier.reportAction == ReportAction.report) {
    return const SizedBox.shrink();
  }

  if (notifier.reportType == ReportType.post &&
      notifier.reportAction == ReportAction.hide) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CustomTextWidget(
            //     maxLines: 2,
            //     textAlign: TextAlign.left,
            //     textStyle: Theme.of(context).textTheme.titleSmall?.apply(color: kHyppeSecondary),
            //     textToDisplay: notifier.language.ifYouThinkGoesAgainstOurMediaSocialCommunityPolicies ?? ''),
            // GestureDetector(
            //     onTap: () {
            //       notifier.appBar = notifier.language.whyAreYouReportingThis ?? '';
            //       notifier.reportType = ReportType.post;
            //       notifier.data = {'userID': notifier.data?['userID'], 'postID': notifier.data?['postID']};
            //       notifier.reportAction = ReportAction.report;
            //       notifier.initData = Report();
            //       Routing().moveAndPop(Routes.report);
            //     },
            //     child: Container(
            //       alignment: Alignment.bottomLeft,
            //       height: 50 * SizeConfig.scaleDiagonal,
            //       child: CustomTextWidget(
            //           textAlign: TextAlign.left,
            //           textToDisplay: notifier.language.reportThisPost ?? '',
            //           textStyle: Theme.of(context).textTheme.labelLarge?.apply(color: kHyppeUploadIcon)),
            //     )),
          ],
        ));
  }

  return const SizedBox.shrink();
}
