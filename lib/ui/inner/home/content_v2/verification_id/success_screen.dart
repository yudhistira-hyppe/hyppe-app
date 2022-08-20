import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
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
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: "ID Verification",
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
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
                const CustomTextWidget(
                    textOverflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                    textToDisplay:
                        "Your account is now Premium. Now you can enjoy these greats benefits:"),
                _buildDivider(context),
                const SizedBox(height: 10),
                _unorderedList(
                    "Register Content Ownership to get Ownership Certificate"),
                _unorderedList("Sell and Buying Content"),
                _unorderedList("Put Ads in Hyppe Apps"),
                _unorderedList("Send balance to your Bank Account"),
                const SizedBox(height: 70)
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
            function: () => notifier.clearAndMoveToLobby(),
            child: CustomTextWidget(
              textToDisplay: "Close",
              textStyle:
                  textTheme.button?.copyWith(color: kHyppeLightButtonText),
            ),
            buttonStyle: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
              shadowColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
              overlayColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primaryVariant),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(context) => Divider(
      thickness: 1.0,
      color: Theme.of(context).dividerTheme.color!.withOpacity(0.1));

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
