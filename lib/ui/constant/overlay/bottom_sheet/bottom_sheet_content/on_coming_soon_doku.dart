import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class OnComingSoonDoku extends StatelessWidget {
  const OnComingSoonDoku({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _language = context.watch<TranslateNotifierV2>().translate;
    return SizedBox(
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.topCenter,
            child: CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}Doku_Wallet_Soon.svg",
                  defaultColor: false,
                ),
                thirtyTwoPx,
                const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}Soon.svg",
                  defaultColor: false,
                ),
                thirtyTwoPx,
                CustomTextWidget(
                  textToDisplay: _language.comingSoon!,
                  textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                ),
                eightPx,
                CustomTextWidget(
                  textToDisplay: _language.weWillNotifyYouOnceThisFeaturedIsReady!,
                  textStyle: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
