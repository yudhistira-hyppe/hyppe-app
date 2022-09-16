import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
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
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.translate.signInAndSecurity!,
            textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
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
              SettingTile(
                icon: 'lock.svg',
                onTap: () => Routing().move(Routes.changePassword),
                caption: '${notifier.translate.password}',
              ),
              SettingTile(
                icon: 'lock-pin.svg',
                onTap: () => Routing().move(Routes.pinScreen),
                caption: setPin == 'true' ? notifier.translate.changePin! : notifier.translate.setPin!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
