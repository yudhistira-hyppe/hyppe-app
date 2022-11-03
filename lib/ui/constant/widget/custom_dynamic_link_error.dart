import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDynamicLinkErrorWidget extends StatelessWidget {
  final Function? function;

  const CustomDynamicLinkErrorWidget({Key? key, this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _language = context.watch<TranslateNotifierV2>().translate;
    return SizedBox(
      height: 262.21,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}dynamic-link-error.svg",
                  defaultColor: false,
                ),
                eightPx,
                CustomTextWidget(textToDisplay: _language.sorryTheresNothingHere ?? '', textStyle: theme.textTheme.subtitle1),
                fourPx,
                CustomTextWidget(
                    textToDisplay: _language.theContentMayHaveBeenRemovedOrTheLinkMayBeBroken ?? '',
                    textStyle: theme.textTheme.caption?.copyWith(color: theme.colorScheme.secondaryVariant))
              ],
            ),
          )
        ],
      ),
    );
  }
}
