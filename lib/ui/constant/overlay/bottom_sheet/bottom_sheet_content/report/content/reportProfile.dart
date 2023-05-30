import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/widget/build_list_tile.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportProfile extends StatelessWidget {
  final String? userID;
  final String? postID;

  const ReportProfile({Key? key, this.userID, this.postID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (context, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          Container(
            alignment: Alignment.center,
            height: 84.5 * (SizeConfig.screenHeight!) / SizeWidget.baseHeightXD,
            child: BuildListTile(
              onTap: () => ShowBottomSheet.onReportAccountContent(context, type: 'report'),
              icon: "${AssetPath.vectorPath}report.svg",
              title: notifier.translate.reportThisAccount ?? '',
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 84.5 * (SizeConfig.screenHeight!) / SizeWidget.baseHeightXD,
            child: BuildListTile(
              onTap: () => ShowBottomSheet.onReportAccountContent(context, type: 'block'),
              icon: "${AssetPath.vectorPath}block.svg",
              title: notifier.translate.blockThisAccount ?? '',
            ),
          ),
        ],
      ),
    );
  }
}
