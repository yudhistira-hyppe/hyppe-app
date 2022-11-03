import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnCancelPostBottomSheet extends StatelessWidget {
  final Function onCancel;
  const OnCancelPostBottomSheet({Key? key, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreUploadContentNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            CustomTextWidget(
              textToDisplay: notifier.language.cancelPost ?? '',
              textStyle: Theme.of(context).textTheme.headline6,
            ),
            CustomTextWidget(
              textToDisplay: notifier.language.areYouSure ?? 'Are you sure?',
              textStyle: Theme.of(context).textTheme.bodyText2,
              textOverflow: TextOverflow.clip,
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.language.yesCancelPost ?? '',
                textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
              ),
              width: double.infinity,
              height: 50,
              function: () {
                Routing().moveBack();
                Routing().moveBack();
                onCancel();
              },
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                  overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant)),
            ),
            CustomElevatedButton(
              child: CustomTextWidget(
                textToDisplay: notifier.language.keepEditing ?? '',
                textStyle: Theme.of(context).textTheme.button,
              ),
              width: double.infinity,
              height: 50,
              function: () => Routing().moveBack(),
              buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent), overlayColor: MaterialStateProperty.all(Colors.transparent)),
            )
          ],
        ),
      ),
    );
  }
}