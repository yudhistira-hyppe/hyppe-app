import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:path/path.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:provider/provider.dart';

class VerificationIDStep7 extends StatefulWidget {
  const VerificationIDStep7({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep7> createState() => _VerificationIDStep7State();
}

class _VerificationIDStep7State extends State<VerificationIDStep7> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.retrySelfie(context);
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Image.file(
                  File(notifier.selfiePath),
                  // notifier.pickedSupportingDocs![0],
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButtonWidget(
                        defaultColor: true,
                        iconData: "${AssetPath.vectorPath}back-arrow.svg",
                        onPressed: () => notifier.retrySelfie(context),
                      ),
                      CustomElevatedButton(
                        width: 120,
                        height: 44.0 * SizeConfig.scaleDiagonal,
                        function: () => notifier.onPickSupportedDocument(context, true),
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.continueStep ?? '',
                          textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                        ),
                        buttonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
