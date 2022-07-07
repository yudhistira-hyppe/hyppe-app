import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnReportContentBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<MakeContentNotifier>(
      builder: (_, notifier, __) => Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
              child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            ),
            ListTile(
              onTap: () {
                ShowBottomSheet.onReportFormContent(context);
              },
              title: CustomTextWidget(
                textToDisplay: notifier.language.iDontWantToSeeThis!,
                textAlign: TextAlign.start,
                textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              subtitle: CustomTextWidget(
                textToDisplay: notifier.language.letUsKnowWhyYouDontWantToSeeThisPost!,
                textAlign: TextAlign.start,
                textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
              ),
              leading: const Icon(Icons.visibility_off_outlined),
              minLeadingWidth: 20,
            ),
            ListTile(
              visualDensity: VisualDensity.adaptivePlatformDensity,
              onTap: () {
                ShowBottomSheet.onReportSpamContent(context);
              },
              dense: true,
              title: CustomTextWidget(
                textToDisplay: notifier.language.reportThisPost!,
                textAlign: TextAlign.start,
                textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              subtitle: CustomTextWidget(
                textToDisplay: notifier.language.thisPostIsOffensiveOrTheAccountIsHacked!,
                textAlign: TextAlign.start,
                textStyle: const TextStyle(fontSize: 12, color: Color(0xffaaaaaa)),
              ),
              leading: const Icon(Icons.warning_amber_rounded),
              minLeadingWidth: 20,
            )
          ],
        ),
      ),
    );
  }
}
