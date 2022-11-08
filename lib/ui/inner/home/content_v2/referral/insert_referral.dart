import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class InsertReferral extends StatefulWidget {
  @override
  _InsertReferralState createState() => _InsertReferralState();
}

class _InsertReferralState extends State<InsertReferral> {
  @override
  Widget build(BuildContext context) {
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
          textToDisplay: 'Masukkan Referal',
          textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: Consumer<ReferralNotifier>(
        builder: (_, notifier, __) => Padding(
          padding: EdgeInsets.only(bottom: 30, left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username Referal'),
                  TextFormField(
                    autofocus: true,
                    onChanged: (value) {
                      notifier.inserReferral = value;
                    },
                    decoration: const InputDecoration(contentPadding: EdgeInsets.all(10)),
                  ),
                ],
              ),
              twentyPx,
              fourPx,
              CustomElevatedButton(
                function: () {
                  if (!notifier.isLoading) {
                    if (notifier.nameReferral.isNotEmpty) {
                      notifier.registerReferral(context);
                    }
                  }
                },
                buttonStyle: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    notifier.isLoading
                        ? Theme.of(context).colorScheme.secondary
                        : notifier.buttonReferralDisable()
                            ? Theme.of(context).colorScheme.primaryVariant
                            : Theme.of(context).colorScheme.secondary,
                  ),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: notifier.isLoading
                    ? const CustomLoading()
                    : CustomTextWidget(
                        textToDisplay: notifier.language.save ?? 'save',
                        textStyle: notifier.buttonReferralDisable() ? Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText) : Theme.of(context).primaryTextTheme.button,
                      ),
                width: SizeConfig.screenWidth,
                height: 49 * SizeConfig.scaleDiagonal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
