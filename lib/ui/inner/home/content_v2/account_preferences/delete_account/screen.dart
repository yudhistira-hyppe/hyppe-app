import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class HyppeDeleteAccoount extends StatelessWidget {
  const HyppeDeleteAccoount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          title: CustomTextWidget(
            textToDisplay: notifier.language.deleteAccount!,
            textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            splashRadius: 1,
            onPressed: () {
              Routing().moveBack();
            },
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      textToDisplay: notifier.language.whyAreYouLeavingHyppe!,
                      textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    eightPx,
                    CustomTextWidget(
                      textToDisplay: notifier.language.wereSorryToSeeYouGo!,
                      textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(),
                      maxLines: 100,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: notifier.optionDelete!.length,
                itemBuilder: (context, index) {
                  return RadioListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    groupValue: notifier.optionDelete![index]['code'],
                    value: notifier.currentOptionDelete,
                    onChanged: (_) {
                      notifier.currentOptionDelete = notifier.optionDelete![index]['code'];
                    },
                    toggleable: true,
                    title: CustomTextWidget(
                      textAlign: TextAlign.left,
                      textToDisplay: notifier.optionDelete![index]['title'],
                      textStyle: Theme.of(context).primaryTextTheme.titleSmall,
                      maxLines: 3,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: Theme.of(context).colorScheme.primaryVariant,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomElevatedButton(
                  width: SizeConfig.screenWidth,
                  height: 49 * SizeConfig.scaleDiagonal,
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.next!,
                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
                  ),
                  function: () => notifier.navigateToConfirmDeleteProfile(),
                  buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      notifier.somethingChanged(context) ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).colorScheme.secondary,
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
