import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationSupportSuccess extends StatefulWidget {
  final GeneralArgument? argument;
  const VerificationSupportSuccess({Key? key, this.argument}) : super(key: key);

  @override
  State<VerificationSupportSuccess> createState() => _VerificationSupportSuccessState();
}

class _VerificationSupportSuccessState extends State<VerificationSupportSuccess> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationSupportSuccess');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          if (widget.argument != null) {
            if (!(widget.argument?.isTrue ?? false)) {
              Routing().moveBack();
            } else {
              notifier.clearAndMoveToLobby();
            }
          } else {
            notifier.clearAndMoveToLobby();
          }

          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CustomTextWidget(
                textToDisplay: notifier.language.idVerification ?? '',
                textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: const Center(
                        child: Image(image: AssetImage("${AssetPath.pngPath}verification-support-success.png")),
                      ),
                    ),
                  ),
                  Text(
                    notifier.language.weWillBeganProcessingYourVerification ?? '',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  sixPx,
                  CustomTextWidget(textOverflow: TextOverflow.visible, textAlign: TextAlign.left, textToDisplay: notifier.language.thisProcessWillTakeUpTo3WorkingDaysPleaseWait ?? ''),
                  sixPx,
                  _buildDivider(context),
                  sixPx,
                  Text(
                    notifier.language.failedIdCardInfoSubTitle ?? '',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  twelvePx,
                  _unorderedList(notifier.language.failedIdCardInfo_1 ?? ''),
                  _unorderedList(notifier.language.failedIdCardInfo_2 ?? ''),
                  _unorderedList(notifier.language.failedIdCardInfo_3 ?? ''),
                  _unorderedList(notifier.language.failedIdCardInfo_4 ?? ''),
                  _unorderedList(notifier.language.failedIdCardInfo_5 ?? ''),
                  CustomTextWidget(textOverflow: TextOverflow.visible, textAlign: TextAlign.left, textToDisplay: notifier.language.supportDocNotice10 ?? ''),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomElevatedButton(
              width: SizeConfig.screenWidth,
              height: 44.0 * SizeConfig.scaleDiagonal,
              function: () {
                if (widget.argument != null) {
                  if (!(widget.argument?.isTrue ?? false)) {
                    Routing().moveBack();
                  } else {
                    notifier.clearAndMoveToLobby();
                  }
                } else {
                  notifier.clearAndMoveToLobby();
                }
              },
              child: CustomTextWidget(
                textToDisplay: notifier.language.close ?? 'close',
                textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
              ),
              buttonStyle: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(context) => Divider(thickness: 1.0, color: Theme.of(context).dividerTheme.color?.withOpacity(0.1));

  Widget _unorderedList(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text("• "), Expanded(child: Text(text))],
      ),
    );
  }
}
