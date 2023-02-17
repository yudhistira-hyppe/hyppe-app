import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:provider/provider.dart';

class PageTop extends StatelessWidget {
  const PageTop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _themeState = SharedPreference().readStorage(SpKeys.themeData) ?? false;

    return Column(
      children: [
        thirtyTwoPx,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIconWidget(
              defaultColor: false,
              iconData: '${AssetPath.vectorPath}logo-purple.svg',
            ),
            eightPx,
            CustomIconWidget(
              defaultColor: false,
              iconData: _themeState ? '${AssetPath.vectorPath}logo-text-white.svg' : '${AssetPath.vectorPath}logo-text-black.svg',
            ),
          ],
        ),
        sixteenPx,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(
              textToDisplay: "#MonetizeYourIdeas",
              textStyle: Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        thirtyTwoPx,
        Image.asset("${AssetPath.pngPath}login_content.png"),
      ],
    );
  }
}
