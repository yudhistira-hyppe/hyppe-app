import 'package:hyppe/core/constants/asset_path.dart';
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
    return Column(
      children: [
        thirtyTwoPx,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIconWidget(
              defaultColor: false,
              iconData: '${AssetPath.vectorPath}hastag.svg',
            ),
            CustomTextWidget(
              textToDisplay: " MonetizeYourIdeas",
              textStyle: Theme.of(context).primaryTextTheme.headline5?.copyWith(
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
