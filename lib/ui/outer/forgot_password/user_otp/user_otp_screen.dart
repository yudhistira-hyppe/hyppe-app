import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/widget/sign_up_pin_top.dart';

import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';

import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../constant/widget/icon_button_widget.dart';

class UserOtpScreen extends StatefulWidget {
  final UserOtpScreenArgument argument;

  const UserOtpScreen({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  _UserOtpScreenState createState() => _UserOtpScreenState();
}

class _UserOtpScreenState extends State<UserOtpScreen> {
  late UserOtpNotifier _notifier;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'UserOtpScreen');
    _notifier = Provider.of<UserOtpNotifier>(context, listen: false);
    _notifier.initState(widget.argument);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<UserOtpNotifier>(
      builder: (context, notifier, child) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: KeyboardDisposal(
            child: Scaffold(
              appBar: AppBar(
                leading: CustomIconButtonWidget(
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () => Navigator.pop(context),
                  iconData: '${AssetPath.vectorPath}back-arrow.svg',
                ),
                automaticallyImplyLeading: false,
                title: CustomTextWidget(
                  textStyle: Theme.of(context).textTheme.headline6,
                  textToDisplay: notifier.language.verificationCode ?? '',
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      child: const SignUpPinTop(),
                      width: SizeConfig.screenWidth,
                      height: (SizeConfig.screenHeight! * 0.7),
                      alignment: const Alignment(0.0, -0.4),
                      padding: const EdgeInsets.only(left: 16, right: 16),
                    ),

                    // SizedBox(
                    //   width: SizeConfig.screenWidth,
                    //   child: SignUpButton(
                    //     withSkipButton: false,
                    //     loading: notifier.isLoading,
                    //     onTap: notifier.onVerifyButton(context),
                    //     caption: notifier.language.verify ?? '',
                    //     textStyle: notifier.verifyTextColor(context),
                    //     buttonColor: notifier.verifyButtonColor(context),
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
