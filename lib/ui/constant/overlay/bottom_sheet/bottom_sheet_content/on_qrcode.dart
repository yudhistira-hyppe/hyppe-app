import 'dart:io';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OnQRCode extends StatefulWidget {
  const OnQRCode({super.key});

  @override
  State<OnQRCode> createState() => _OnQRCodeState();
}

class _OnQRCodeState extends State<OnQRCode> {
  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    SizeConfig().init(context);
    return Consumer<ChallangeNotifier>(
      builder: (_, notifier, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: Platform.isIOS ? 50 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                sixteenPx,
                CustomTextWidget(
                  textToDisplay: notifier.language.postTo ?? '',
                  textStyle: Theme.of(context).textTheme.headline6,
                ),
                QrImageView(
                  data: notifier.referralLink,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                sixteenPx,
                CustomTextWidget(
                  textToDisplay: 'QR Code',
                  textStyle: Theme.of(context).textTheme.headline6,
                ),
                const Text(
                  'Undang temanmu ke Hyppe sekarang!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF9B9B9B),
                    fontSize: 14,
                  ),
                ),
                thirtyTwoPx,
                ButtonChallangeWidget(
                  text: tn.translate.shareYourQR,
                  bgColor: kHyppePrimary,
                  borderColor: kHyppePrimary,
                  textColors: kHyppeTextPrimary,
                  function: () {
                    System().shareText(dynamicLink: notifier.referralLink, context: context);
                    // navigate(context, tn, cn, widgetTwo: widgetTwo);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
