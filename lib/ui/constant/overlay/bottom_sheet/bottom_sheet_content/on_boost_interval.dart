import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnBoostIntervalContent extends StatelessWidget {
  const OnBoostIntervalContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreUploadContentNotifier>(
      builder: (context, notifier, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                  sixteenPx,
                  CustomTextWidget(
                    textToDisplay: notifier.language.interval ?? 'Interval',
                    // '$captionTitle ${contentData?.content.length == 1 ? contentData?.content.length : contentIndex} of ${contentData?.content.length}',
                    textStyle: Theme.of(context).primaryTextTheme.headline6?.copyWith(),
                  ),
                  thirtySixPx,
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifier.boostMasterData?.interval?.length ?? 0,
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          groupValue: notifier.tmpBoostIntervalId,
                          value: "${notifier.boostMasterData?.interval?[index].sId}",
                          onChanged: (val) {
                            notifier.tmpBoostInterval =
                                "${notifier.boostMasterData?.interval?[index].value} ${System().capitalizeFirstLetter(notifier.boostMasterData?.interval?[index].remark ?? '')}";
                            notifier.tmpBoostIntervalId = val ?? '';
                          },
                          title: CustomTextWidget(
                            textAlign: TextAlign.left,
                            textToDisplay: "${notifier.boostMasterData?.interval?[index].value} ${System().capitalizeFirstLetter(notifier.boostMasterData?.interval?[index].remark ?? '')}",
                            textStyle: Theme.of(context).primaryTextTheme.subtitle1?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          activeColor: Theme.of(context).colorScheme.primaryVariant,
                        );
                      }),
                  twentyFourPx,
                  CustomTextButton(
                    onPressed: notifier.tmpBoostInterval != ''
                        ? () {
                            Routing().moveBack();
                          }
                        : null,
                    style: ButtonStyle(backgroundColor: notifier.tmpBoostInterval != '' ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
                    child: Container(
                      width: SizeConfig.screenWidth,
                      padding: const EdgeInsets.all(10),
                      child: CustomTextWidget(
                        textToDisplay: notifier.language.save ?? 'confirm',
                        textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
