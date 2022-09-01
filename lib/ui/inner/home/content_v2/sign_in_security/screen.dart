import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.translate.signInAndSecurity!,
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingTile(
                icon: 'lock.svg',
                onTap: () => Routing().move(Routes.changePassword),
                caption: '${notifier.translate.changePassword}',
              ),
              SettingTile(
                icon: 'verification-icon.svg',
                onTap: () => Routing().move(Routes.verificationIDStep1),
                caption: '${notifier.translate.idVerification}',
                trailing: verificationStatus(
                    context, 'unverified'), //verified, unverified, review
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
    switch (status) {
      case "verified":
        statusText = "Verified";
        statusColor = Colors.black87;
        bgColor = const Color.fromRGBO(171, 34, 175, 0.08);
        break;
      case "unverified":
        statusText = "Unerified";
        statusColor = Colors.white;
        bgColor = kHyppePrimary;
        break;
      case "review":
        statusText = "Under Review";
        statusColor = Colors.yellow[900];
        bgColor = Colors.yellow[200];
        break;
      default:
        statusText = "Unerified";
        statusColor = Colors.white;
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
              decoration: BoxDecoration(
                  color: kHyppePrimary,
                  borderRadius: BorderRadius.circular(10)),
              child: const CustomIconWidget(
                defaultColor: false,
                height: 5,
                width: 5,
                iconData: "${AssetPath.vectorPath}checkmark.svg",
              ),
            ),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}
