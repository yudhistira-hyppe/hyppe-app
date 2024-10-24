import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class VerificationIDStep7 extends StatefulWidget {
  final bool isFromBack;
  const VerificationIDStep7({Key? key, required this.isFromBack})
      : super(key: key);

  @override
  State<VerificationIDStep7> createState() => _VerificationIDStep7State();
}

class _VerificationIDStep7State extends State<VerificationIDStep7> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDStep7');
    super.initState();
  }

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
                Platform.isIOS
                    ? Transform(
                        transform: Matrix4.rotationY(math.pi),
                        alignment: Alignment.center,
                        child: Image.file(
                          File(notifier.selfiePath),
                          // notifier.pickedSupportingDocs![0],
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                        ),
                      )
                    : widget.isFromBack
                        ? Image.file(
                            File(notifier.selfiePath),
                            // notifier.pickedSupportingDocs![0],
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                            alignment: Alignment.center,
                          )
                        : Transform(
                            transform: Matrix4.rotationY(math.pi),
                            alignment: Alignment.center,
                            child: Image.file(
                              File(notifier.selfiePath),
                              // notifier.pickedSupportingDocs![0],
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              alignment: Alignment.center,
                            ),
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
                        function: () =>
                            notifier.onPickSupportedDocument(context, true),
                        buttonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                          shadowColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                          overlayColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primary),
                        ),
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.continueStep ?? '',
                          textStyle: textTheme.labelLarge
                              ?.copyWith(color: kHyppeLightButtonText),
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
