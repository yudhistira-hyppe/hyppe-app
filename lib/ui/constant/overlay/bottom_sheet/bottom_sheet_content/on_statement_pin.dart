import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class OnStatementPinBottomSheet extends StatelessWidget {
  Function()? onSave;
  Function()? onCancel;
  String? title;
  String? bodyText;
  OnStatementPinBottomSheet({Key? key, this.onSave, this.onCancel, this.title, this.bodyText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      key: key,
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal, horizontal: 16 * SizeConfig.scaleDiagonal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            thirtySixPx,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title == ''
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Center(
                          child: CustomTextWidget(
                            textToDisplay: title ?? '',
                            textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                            maxLines: 2,
                          ),
                        ),
                      ),
                CustomTextWidget(
                  textToDisplay: bodyText ?? '',
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground),
                  maxLines: 100,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            twentyFourPx,
            onSave == null
                ? Container()
                : CustomElevatedButton(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    function: onSave,
                    child: CustomTextWidget(
                      textToDisplay: notifier.translate.goToSecurityPrivacy ?? '',
                    ),
                    buttonStyle: ButtonStyle(
                      // backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.background),
                      backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                      shadowColor: MaterialStateProperty.all(Colors.white),
                      elevation: MaterialStateProperty.all(0),
                      side: MaterialStateProperty.all(
                        BorderSide(color: kHyppeLightInactive1, width: 1.0, style: BorderStyle.solid),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}
