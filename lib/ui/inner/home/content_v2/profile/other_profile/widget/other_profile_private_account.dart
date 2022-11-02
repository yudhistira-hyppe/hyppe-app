import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherProfilePrivateAccount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.49,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomIconWidget(iconData: "${AssetPath.vectorPath}private.svg"),
          SizedBox(height: 6 * SizeConfig.scaleDiagonal),
          CustomTextWidget(textToDisplay: context.read<TranslateNotifierV2>().translate.privateAccount ?? '', textStyle: Theme.of(context).textTheme.bodyText2),
          CustomTextWidget(
            textToDisplay: context.read<TranslateNotifierV2>().translate.followThisAccountToSeeTheirContents ?? '',
            textStyle: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondaryVariant,
            ),
          ),
        ],
      ),
    );
  }
}
