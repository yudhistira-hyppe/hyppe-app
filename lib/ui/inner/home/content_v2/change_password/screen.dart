import 'package:hyppe/ui/inner/home/content_v2/change_password/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/change_password/widget/button_change_password.dart';
import 'package:hyppe/ui/inner/home/content_v2/change_password/widget/text_input_change_password.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HyppeChangePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<ChangePasswordNotifier>(
      builder: (_, notifier, __) => GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: WillPopScope(
          onWillPop: notifier.onWillPop,
          child: Scaffold(
            appBar: AppBar(
              leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
              leading: IconButton(
                icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                splashRadius: 1,
                onPressed: () {
                  notifier.clearTxt();
                  Navigator.pop(context);
                },
              ),
              titleSpacing: 0,
              title: CustomTextWidget(
                textToDisplay: notifier.language.changePassword!,
                textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18 * SizeConfig.scaleDiagonal),
              ),
              centerTitle: false,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25.0),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(text: notifier.language.createNewPassword!, style: Theme.of(context).textTheme.bodyText1!, children: <TextSpan>[
                      const TextSpan(text: "\n\n"),
                      TextSpan(
                        text: notifier.language.passwordAreCaseSensitiveAndMustBeAtLeast8Characters,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: kHyppeSecondary),
                      )
                    ]),
                  ),
                  TextInputChangePassword(),
                ],
              ),
            ),
            resizeToAvoidBottomInset: false,
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: ButtonChangePassword(
                    loading: notifier.onSave,
                    caption: notifier.language.save!,
                    buttonColor: notifier.saveButtonColor(context),
                    textStyle: notifier.saveTextColor(context),
                    onTap: () => notifier.onClickSave(context),
                  ),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
                // ButtonChangePassword(
                //   caption: notifier.language.forgotPassword! + "?",
                //   onTap: () => Routing().move(resetPassword),
                //   buttonColor: Colors.transparent,
                //   captionColor: Colors.white,
                // ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ),
      ),
    );
  }
}
