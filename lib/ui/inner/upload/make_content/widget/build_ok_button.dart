import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildOkButton extends StatelessWidget {
  final bool mounted;

  const BuildOkButton({Key? key, required this.mounted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      width: 81,
      height: 30,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}checkmark.svg",
              defaultColor: false),
          fivePx,
          CustomTextWidget(
            textToDisplay: 'Ok',
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: kHyppeLightButtonText, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      buttonStyle: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0)))),
      function: () =>
          context.read<MakeContentNotifier>().onStopRecordedVideo(context),
    );
  }
}
