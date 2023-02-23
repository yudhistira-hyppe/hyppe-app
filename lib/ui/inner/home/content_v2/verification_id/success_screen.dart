import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDSuccess extends StatefulWidget {
  const VerificationIDSuccess({Key? key}) : super(key: key);

  @override
  State<VerificationIDSuccess> createState() => _VerificationIDSuccessState();
}

class _VerificationIDSuccessState extends State<VerificationIDSuccess> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.clearAndMoveToLobby();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => notifier.clearAndMoveToLobby(),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier.language.idVerification ?? '',
              textStyle:
                  Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Image(
                        image: AssetImage(
                            "${AssetPath.pngPath}verification-success.png")),
                  ),
                  CustomTextWidget(
                      textOverflow: TextOverflow.visible,
                      textAlign: TextAlign.left,
                      textToDisplay: notifier.language.successIdCardTitle ?? ''),
                  _buildDivider(context),
                  const SizedBox(height: 10),
                  _unorderedList(notifier.language.successIdCard1 ?? ''),
                  _unorderedList(notifier.language.successIdCard2 ?? ''),
                  _unorderedList(notifier.language.successIdCard3 ?? ''),
                  _unorderedList(notifier.language.successIdCard4 ?? ''),
                  const SizedBox(height: 70)
                ],
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomElevatedButton(
              width: SizeConfig.screenWidth,
              height: 44.0 * SizeConfig.scaleDiagonal,
              function: () => notifier.clearAndMoveToLobby(),
              child: CustomTextWidget(
                textToDisplay: notifier.language.close ?? 'close',
                textStyle:
                    textTheme.button?.copyWith(color: kHyppeLightButtonText),
              ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(context) => Divider(
      thickness: 1.0,
      color: Theme.of(context).dividerTheme.color?.withOpacity(0.1));

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
