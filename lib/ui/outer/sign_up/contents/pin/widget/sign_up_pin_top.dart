import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/widget/custom_rectangle_input.dart';
import 'package:provider/provider.dart';

class SignUpPinTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}verification-email.svg",
          ),
          twentyPx,
          CustomTextWidget(
            textStyle: Theme.of(context).textTheme.bodyText2,
            textToDisplay: notifier.language.pinTopText! + " ${notifier.email}",
          ),
          fortyTwoPx,
          CustomRectangleInput(),
          // twelvePx,
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     CustomTextWidget(
          //       textStyle: Theme.of(context).textTheme.caption,
          //       textToDisplay: notifier.language.didntReceiveTheCode ?? '',
          //     ),
          //     fourPx,
          //     InkWell(
          //       onTap: notifier.resendCode(context),
          //       child: CustomTextWidget(
          //         textOverflow: TextOverflow.visible,
          //         textToDisplay: notifier.resendString(),
          //         textStyle: notifier.resendStyle(context),
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
