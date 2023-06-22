import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class OfflineMode extends StatelessWidget {
  final Function()? function;
  const OfflineMode({Key? key, this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OfflineMode');
    return Column(
      children: <Widget>[
        Expanded(
            child: SizedBox(
          width: SizeConfig.screenWidth,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  textToDisplay: tn.translate.oopsYoureOffline ?? '',
                  maxLines: 2,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                eightPx,
                CustomTextWidget(
                  textToDisplay: tn.translate.checkYourWiFiConnectionOrInternet ?? '',
                  maxLines: 2,
                  textStyle: const TextStyle(color: kHyppeSecondary),
                ),
                twentyPx,
                CustomTextButton(
                  onPressed: () => function?.call(),
                  style: ButtonStyle(side: MaterialStateProperty.all(const BorderSide(color: kHyppePrimary, width: 1.0, style: BorderStyle.solid))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: CustomTextWidget(
                      textToDisplay: tn.translate.tryAgain ?? '',
                      textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppePrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}