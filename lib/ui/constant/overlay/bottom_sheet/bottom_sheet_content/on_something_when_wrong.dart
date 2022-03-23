import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnSomethingWhenWrong extends StatelessWidget {
  const OnSomethingWhenWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Container(
        padding: EdgeInsets.all(55 * SizeConfig.scaleDiagonal),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              "${AssetPath.pngPath}content-error.png",
              width: 250 * SizeConfig.scaleDiagonal,
              height: 160 * SizeConfig.scaleDiagonal,
            ),
            SizedBox(height: 35 * SizeConfig.scaleDiagonal),
            CustomTextWidget(
              textToDisplay: notifier.translate.somethingsWrong!,
              textAlign: TextAlign.center,
              textStyle: TextStyle(fontSize: 18 * SizeConfig.scaleDiagonal, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14 * SizeConfig.scaleDiagonal),
            CustomTextWidget(
              textToDisplay: notifier.translate.pleaseTryAgain!,
              textAlign: TextAlign.center,
              textStyle: Theme.of(context).textTheme.bodyText2,
              textOverflow: TextOverflow.clip,
            )
          ],
        ),
      ),
    );
  }
}
