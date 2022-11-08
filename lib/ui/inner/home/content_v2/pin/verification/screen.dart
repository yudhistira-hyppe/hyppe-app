import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/verification/widget/verification_pin_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/pin/verification/widget/verification_pin_top.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
// import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';

// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';

class VerificationPin extends StatefulWidget {
  const VerificationPin({Key? key}) : super(key: key);

  @override
  _VerificationPinState createState() => _VerificationPinState();
}

class _VerificationPinState extends State<VerificationPin> with AfterFirstLayoutMixin {
  late SignUpPinNotifier _notifier;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _notifier.resetTimer();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // _notifier = Provider.of<SignUpPinNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer2<PinAccountNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => KeyboardDisposal(
        // onTap: () => notifier.unFocusingNode(),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Routing().moveBack();
                notifier.otpController.clear();
                notifier.otpVerified = '';
              },
              child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
            ),
            automaticallyImplyLeading: false,
            title: CustomTextWidget(
              textToDisplay: notifier2.translate.verificationCode ?? '',
              textStyle: Theme.of(context).textTheme.headline6,
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height / 1.13,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: VerificationPinTop(),
                    ),
                    VerificationPinBottom(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
