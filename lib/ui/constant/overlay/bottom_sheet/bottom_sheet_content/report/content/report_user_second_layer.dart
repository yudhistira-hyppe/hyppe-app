import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/inner/home/content/profile/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/widget/build_list_tile.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportUserSecondLayer extends StatelessWidget {
  final String? userID;

  const ReportUserSecondLayer({Key? key, this.userID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<ReportNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.screen = false;
          return false;
        },
        child: Consumer<TranslateNotifierV2>(
          builder: (context, notifier, child) => Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
                child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
              ),
              BuildListTile(
                onTap: () => _navigateToHyppeBlock(context),
                icon: "${AssetPath.vectorPath}block.svg",
                // title: "${notifier.translate.block} ${notifier.peopleProfile.profileOverviewData.userOverviewData.username}",
                title: "${notifier.translate.block} dummy_user",
                subtitle: notifier.translate.blockCaption ?? '',
              ),
              BuildListTile(
                onTap: () => _navigateToHyppeReportProfile(context),
                icon: "${AssetPath.vectorPath}report.svg",
                title: notifier.translate.reportThisProfile ?? '',
                subtitle: notifier.translate.reportCaption ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHyppeReportProfile(BuildContext context) async {
    final notifier = Provider.of<ReportNotifier>(context, listen: false);
    Routing().moveBack();
    notifier.data = {'userID': userID, 'ruserID': SharedPreference().readStorage(SpKeys.userID), 'reportType': 'profile'};
    // notifier.appBar = notifier.language.reportThisProfile;
    notifier.reportType = ReportType.profile;
    notifier.reportAction = ReportAction.report;
    Routing().move(Routes.report);
  }

  void _navigateToHyppeBlock(BuildContext context) async {
    final notifier = Provider.of<ReportNotifier>(context, listen: false);
    Routing().moveBack();
    notifier.data = {'userID': userID, 'ruserID': SharedPreference().readStorage(SpKeys.userID), 'reportType': 'profile'};
    // notifier.appBar = notifier.language.blockHeader;
    // notifier.fABCaption = notifier.language.block ?? '';
    notifier.reportType = ReportType.profile;
    notifier.reportAction = ReportAction.block;
    Routing().move(Routes.report);
  }
}
