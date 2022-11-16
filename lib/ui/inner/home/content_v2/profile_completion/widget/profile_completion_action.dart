import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ProfileCompletionAction extends StatefulWidget {
  const ProfileCompletionAction({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionAction> createState() =>
      _ProfileCompletionActionState();
}

class _ProfileCompletionActionState extends State<ProfileCompletionAction> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Column(
        children: [
          CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 49 * SizeConfig.scaleDiagonal,
            child: CustomTextWidget(
              textToDisplay: notifier.language.confirm ?? 'Confirm',
              textStyle: notifier.somethingChanged(context)
                  ? Theme.of(context)
                      .textTheme
                      .button?.copyWith(color: kHyppeLightButtonText)
                  : Theme.of(context).primaryTextTheme.button,
            ),
            function: () => notifier.onClickCompletionProfile(context),
            buttonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                notifier.somethingChanged(context)
                    ? Theme.of(context).colorScheme.primaryVariant
                    : Theme.of(context).colorScheme.secondary,
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ),
          twelvePx,
          CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 49 * SizeConfig.scaleDiagonal,
            child: CustomTextWidget(
              textToDisplay: notifier.language.cancel ?? 'Cancel',
              textStyle: Theme.of(context).primaryTextTheme.button,
            ),
            function: () => {Routing().moveBack()},
            buttonStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondary),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
          )
        ],
      ),
    );
  }
}
