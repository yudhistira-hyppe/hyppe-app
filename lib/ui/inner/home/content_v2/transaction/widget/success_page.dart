import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class SuccessPageTransaction extends StatefulWidget {
  const SuccessPageTransaction({Key? key}) : super(key: key);

  @override
  State<SuccessPageTransaction> createState() => _SuccessPageTransactionState();
}

class _SuccessPageTransactionState extends State<SuccessPageTransaction> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SuccessPageTransaction');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    var language = context.read<TranslateNotifierV2>().translate;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: const Center(
                    child: Image(image: AssetImage("${AssetPath.pngPath}verification-support-success.png")),
                  ),
                ),
              ),
              fortyPx,
              Text(
                language.titleSuccessAppealBank ?? '',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              fortyPx,
              Text(
                language.descSuccessAppealBank ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.7),
              ),
              fortyPx,
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 44.0 * SizeConfig.scaleDiagonal,
            function: () {
              Routing().moveBack();
              Routing().moveBack();
            },
            child: CustomTextWidget(
              textToDisplay: language.finish ?? 'selesai',
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
