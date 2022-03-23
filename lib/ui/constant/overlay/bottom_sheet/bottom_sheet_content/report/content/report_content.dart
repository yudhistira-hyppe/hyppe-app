import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/widget/build_list_tile.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportContent extends StatelessWidget {
  final bool fromLandscapeMode;
  final String? userID;
  final String? postID;
  final String? storyID;
  final String? commentID;
  final ReportType? reportType;
  ReportContent({this.fromLandscapeMode = false, this.userID, this.postID, this.storyID, this.commentID, this.reportType});

  final _routing = Routing();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          Container(
            height: 84.5 * SizeConfig.screenHeight! / SizeWidget.baseHeightXD,
            alignment: Alignment.center,
            child: BuildListTile(
                onTap: () => reportHide(context),
                icon: "${AssetPath.vectorPath}eye-off.svg",
                title: notifier.translate.iDontWantToSeeThis!,
                subtitle: notifier.translate.letUsKnowWhyYouDontWantToSeeThisPost!),
          ),
          if (fromLandscapeMode) sixteenPx,
          Container(
            alignment: Alignment.center,
            height: 84.5 * SizeConfig.screenHeight! / SizeWidget.baseHeightXD,
            child: BuildListTile(
                onTap: () => reportReport(context),
                icon: "${AssetPath.vectorPath}report.svg",
                title: notifier.translate.reportThisPost!,
                subtitle: notifier.translate.thisPostIsOffensiveOrTheAccountIsHacked!),
          )
        ],
      ),
    );
  }

  reportHide(context) {
    final notifier = Provider.of<ReportNotifier>(context, listen: false);
    final language = Provider.of<TranslateNotifierV2>(context, listen: false);
    switch (reportType) {
      case ReportType.post:
        {
          notifier.data = {'userID': userID, 'postID': postID};
          notifier.appBar = language.translate.dontWantToSeeThis!;
          notifier.reportType = reportType;
          notifier.reportAction = ReportAction.hide;
          notifier.fromLandscapeMode = fromLandscapeMode;
          _routing.move(Routes.report);
        }
        break;
      case ReportType.story:
        {
          notifier.data = {'userID': userID, 'storyID': storyID};
          notifier.appBar = language.translate.dontWantToSeeThis!;
          notifier.reportType = reportType;
          notifier.reportAction = ReportAction.hide;
          notifier.fromLandscapeMode = fromLandscapeMode;
          _routing.move(Routes.report);
        }
        break;
      case ReportType.comment:
        {
          notifier.data = {'userID': userID, 'postID': postID, 'commentID': commentID};
          notifier.appBar = language.translate.dontWantToSeeThis!;
          notifier.reportType = reportType;
          notifier.reportAction = ReportAction.hide;
          notifier.fromLandscapeMode = fromLandscapeMode;
          _routing.move(Routes.report);
        }
        break;
      default:
        print("Error reportHide: reportType not registered");
        break;
    }
  }

  reportReport(context) {
    final notifier = Provider.of<ReportNotifier>(context, listen: false);
    final language = Provider.of<TranslateNotifierV2>(context, listen: false);
    switch (reportType) {
      case ReportType.post:
        {
          notifier.data = {'userID': userID, 'postID': postID};
          notifier.appBar = language.translate.whyAreYouReportingThis!;
          notifier.reportType = reportType;
          notifier.reportAction = ReportAction.report;
          notifier.fromLandscapeMode = fromLandscapeMode;
          _routing.move(Routes.report);
        }
        break;
      case ReportType.story:
        {
          notifier.data = {'userID': userID, 'storyID': storyID};
          notifier.appBar = language.translate.whyAreYouReportingThis!;
          notifier.reportType = reportType;
          notifier.reportAction = ReportAction.report;
          notifier.fromLandscapeMode = fromLandscapeMode;
          _routing.move(Routes.report);
        }
        break;
      case ReportType.comment:
        {
          notifier.data = {'userID': userID, 'postID': postID, 'commentID': commentID};
          notifier.appBar = language.translate.whyAreYouReportingThis!;
          notifier.reportType = reportType;
          notifier.reportAction = ReportAction.report;
          notifier.fromLandscapeMode = fromLandscapeMode;
          _routing.move(Routes.report);
        }
        break;
      default:
        print("Error reportReport: reportType not registered");
        break;
    }
  }
}
