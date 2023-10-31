import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnInternalServerErrorBottomSheet extends StatelessWidget {
  final int? statusCode;

  const OnInternalServerErrorBottomSheet({
    Key? key,
    this.statusCode = 500,
  }) : super(key: key);

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
            CustomTextWidget(
              textToDisplay: (statusCode ?? 500) >= 500
                ? '${notifier.translate.hyppeServerErrorMessageTitle}'
                : '${notifier.translate.internalServerError}',
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 18 * SizeConfig.scaleDiagonal,
                fontWeight: FontWeight.bold,
                color: kHyppePrimary
              ),
            ),
            SizedBox(height: 4 * SizeConfig.scaleDiagonal),
            CustomTextWidget(
              textToDisplay: (statusCode ?? 500) >= 500
                ? '${notifier.translate.hyppeServerErrorMessageContent}'
                : "${notifier.translate.ourSystemIsCurrentlyExperiencingTechnicalIssues} ${notifier.translate.pleaseTryAgain}",
              textAlign: TextAlign.center,
              textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.4),
              textOverflow: TextOverflow.clip,
            ),
            SizedBox(height: 37 * SizeConfig.scaleDiagonal),
            Image.asset(
              (statusCode ?? 500) >= 500
              ? "${AssetPath.pngPath}enjoying-life.png"
              : "${AssetPath.pngPath}internal_server_error.png",
              // width: 250 * SizeConfig.scaleDiagonal,
              // height: 160 * SizeConfig.scaleDiagonal,
            ),
            SizedBox(height: 35 * SizeConfig.scaleDiagonal),
            CustomElevatedButton(
              width: 164 * SizeConfig.scaleDiagonal,
              height: 42 * SizeConfig.scaleDiagonal,
              function: () async {
                if ((statusCode ?? 500) >= 500) {
                  Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
                } else {
                  context.read<SettingNotifier>().logOut(context);
                  await SharedPreference().logOutStorage();
                  Routing().moveAndRemoveUntil(Routes.welcomeLogin, Routes.root);
                }
              },
              buttonStyle: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(0.0),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)))),
              child: CustomTextWidget(
                textToDisplay: statusCode.toString().startsWith('5')
                    ? notifier.translate.refresh ?? 'Refresh'
                    : notifier.translate.tryAgain ?? 'Try Again',
                textStyle: Theme.of(context)
                    .textTheme
                    .button
                    ?.copyWith(color: kHyppeLightButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
