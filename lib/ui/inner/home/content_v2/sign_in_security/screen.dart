import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/widget/setting_tile.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HyppeHomeSignAndSecurity extends StatelessWidget {
  var setPin = SharedPreference().readStorage(SpKeys.setPin);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.translate.signInAndSecurity ?? '',
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SharedPreference().readStorage(SpKeys.isLoginSosmed) == 'true'
                  ? Container()
                  : SettingTile(
                      icon: 'lock.svg',
                      onTap: () => Routing().move(Routes.changePassword),
                      caption: '${notifier.translate.password}',
                    ),
              SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED
                  ? SettingTile(
                      icon: 'lock-pin.svg',
                      onTap: () => Routing().move(Routes.pinScreen),
                      caption: setPin == 'true' ? notifier.translate.changePin ?? '' : notifier.translate.setPin ?? '',
                    )
                  : Container(),
              SettingTile(
                icon: 'verification-icon.svg',
                onTap: () {
                  switch (SharedPreference().readStorage(SpKeys.statusVerificationId)) {
                    case REVIEW:
                      // ShowBottomSheet().onShowColouredSheet(
                      //   context,
                      //   "Your kyc request under review",
                      //   color: Theme.of(context).colorScheme.error,
                      //   maxLines: 2,
                      // );
                      break;
                    case VERIFIED:
                      // ShowBottomSheet().onShowColouredSheet(
                      //   context,
                      //   "Your kyc status is verified",
                      //   color: Theme.of(context).colorScheme.error,
                      //   maxLines: 2,
                      // );
                      break;
                    default:
                      Routing().move(Routes.verificationIDStep1);
                  }
                },
                caption: '${notifier.translate.idVerification}',
                trailing: verificationStatus(context, SharedPreference().readStorage(SpKeys.statusVerificationId) ?? UNVERIFIED), //verified, unverified, review
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container verificationStatus(BuildContext context, String status) {
    String statusText;
    Color? statusColor;
    Color? bgColor;
    final isDark = context.isDarkMode();
    switch (status) {
      case VERIFIED:
        statusText = "Verified";
        statusColor = isDark ? Colors.white : Colors.black87;
        bgColor = const Color.fromRGBO(171, 34, 175, 0.08);
        break;
      case UNVERIFIED:
        statusText = "Unverified";
        statusColor = isDark ? Colors.black87 : Colors.white;
        bgColor = kHyppePrimary;
        break;
      case REVIEW:
        statusText = "Under Review";
        statusColor = Colors.yellow[900];
        bgColor = Colors.yellow[200];
        break;
      default:
        statusText = "Unverified";
        statusColor = isDark ? Colors.black87 : Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (status == 'verified')
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: kHyppePrimary, borderRadius: BorderRadius.circular(10)),
              child: const CustomIconWidget(
                defaultColor: false,
                height: 5,
                width: 5,
                iconData: "${AssetPath.vectorPath}checkmark.svg",
              ),
            ),
          const SizedBox(width: 5),
          CustomTextWidget(
            textToDisplay: statusText,
            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}
