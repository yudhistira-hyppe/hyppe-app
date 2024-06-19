import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
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
import 'package:showcaseview/showcaseview.dart';

class HyppeHomeSignAndSecurity extends StatelessWidget {
  final setPin = SharedPreference().readStorage(SpKeys.setPin);
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppeHomeSignAndSecurity');
    SizeConfig().init(context);
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => ShowCaseWidget(
        onStart: (index, key) {
          print('onStart: $index, $key');
        },
        onComplete: (index, key) {
          print('onComplete: $index, $key');
        },
        blurValue: 0,
        disableBarrierInteraction: true,
        disableMovingAnimation: true,
        builder: Builder(builder: (context) {
          return Scaffold(
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
                  SharedPreference().readStorage(SpKeys.isLoginSosmed) == 'socmed'
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
                      // Routing().move(Routes.verificationIDStep1);

                      switch (SharedPreference().readStorage(SpKeys.statusVerificationId)) {
                        case REVIEW:
                          Routing().move(Routes.verificationSupportSuccess, argument: GeneralArgument(isTrue: false));
                          break;
                        case VERIFIED:
                          Routing().move(Routes.verifiedScreen);

                          break;
                        default:
                          Routing().move(Routes.verificationIDStep1);
                      }
                    },
                    caption: '${notifier.translate.idVerification}',
                    trailing: verificationStatus(context, SharedPreference().readStorage(SpKeys.statusVerificationId) ?? notifier.translate.unverified, notifier), //verified, unverified, review
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget verificationStatus(BuildContext context, String status, TranslateNotifierV2 notifier) {
    String statusText;
    Color statusColor = const Color(0xffE6094B);
    Color bgColor = const Color(0xffFFE8E5);

    switch (status) {
      case VERIFIED:
        statusText = "Verified";
        statusColor = const Color(0xff01864E);
        bgColor = const Color(0xffE5F5ED);
        break;
      case UNVERIFIED:
        statusText = notifier.translate.unverified ?? 'Unverified';
        break;
      case REVIEW:
        statusText = notifier.translate.localeDatetime == 'id' ? "Ditinjau" : "Reviews";
        break;
      default:
        statusText = notifier.translate.unverified ?? 'Unverified';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // if (status == 'verified')
              //   Container(
              //     padding: const EdgeInsets.all(5),
              //     decoration: BoxDecoration(color: kHyppePrimary, borderRadius: BorderRadius.circular(10)),
              //     child: const CustomIconWidget(
              //       defaultColor: false,
              //       height: 5,
              //       width: 5,
              //       iconData: "${AssetPath.vectorPath}checkmark.svg",
              //     ),
              //   ),
              // const SizedBox(width: 5),
              CustomTextWidget(
                textToDisplay: statusText,
                textStyle: Theme.of(context).textTheme.caption?.copyWith(color: statusColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          color: kHyppeTextLightPrimary,
          size: 26,
        )
      ],
    );
  }
}
