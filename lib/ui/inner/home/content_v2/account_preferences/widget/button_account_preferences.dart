import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:provider/provider.dart';

class ButtonAccountPreferences extends StatelessWidget {
  final int? index;


  const ButtonAccountPreferences({Key? key, this.index}) : super(key: key);
  @override
  Widget build(BuildContext context){
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ButtonAccountPreferences');
    return Consumer<AccountPreferencesNotifier>(
      builder: (context, notifier, child) => CustomElevatedButton(
        width: SizeConfig.screenWidth,
        height: 49 * SizeConfig.scaleDiagonal,
        function: () => notifier.onClickSaveProfile(context),
        buttonStyle: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            notifier.somethingChanged(context) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          ),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: CustomTextWidget(
          textToDisplay: " ${notifier.language.save}",
          textStyle: notifier.somethingChanged(context) ? Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) : Theme.of(context).primaryTextTheme.button,
        ),
      ),
    );
  }
}
