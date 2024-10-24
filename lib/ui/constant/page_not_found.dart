import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Consumer<TranslateNotifierV2>(
        builder: (_, notifier, __) => Container(
          padding: EdgeInsets.all(55 * SizeConfig.scaleDiagonal),
          color: Theme.of(context).colorScheme.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                "${AssetPath.pngPath}page_not_found.png",
                width: 250 * SizeConfig.scaleDiagonal,
                height: 160 * SizeConfig.scaleDiagonal,
              ),
              SizedBox(height: 35 * SizeConfig.scaleDiagonal),
              CustomTextWidget(
                textToDisplay: notifier.translate.pageNotFound ?? '',
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                    fontSize: 18 * SizeConfig.scaleDiagonal,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 14 * SizeConfig.scaleDiagonal),
              CustomTextWidget(
                textToDisplay: notifier.translate
                        .sorryThePageWasNotFoundPleaseReturnToTheHomePage ??
                    '',
                textAlign: TextAlign.center,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                textOverflow: TextOverflow.clip,
              ),
              SizedBox(height: 37 * SizeConfig.scaleDiagonal),
              CustomElevatedButton(
                child: CustomTextWidget(
                  textToDisplay: notifier.translate.backToHome ?? '',
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                width: 164 * SizeConfig.scaleDiagonal,
                height: 42 * SizeConfig.scaleDiagonal,
                function: () => Routing().move(Routes.root),
                buttonStyle: ButtonStyle(
                    elevation: MaterialStateProperty.all<double>(0.0),
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
