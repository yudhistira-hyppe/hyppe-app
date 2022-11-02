import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/user_otp_notifier.dart';
import 'package:hyppe/ui/outer/forgot_password/user_otp/widget/sign_up_pin_top.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_button.dart';

import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/arguments/user_otp_screen_argument.dart';

import 'package:hyppe/ui/constant/widget/keyboard_disposal.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

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
    _notifier = Provider.of<UserOtpNotifier>(context, listen: false);
    _notifier.initState(widget.argument);
    super.initState();
  }

  @override
  void dispose() {
    _notifier.resetTimer();
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
                centerTitle: true,
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
                      height: (SizeConfig.screenHeight ?? context.getHeight() * 0.7),
                      alignment: const Alignment(0.0, -0.4),
                      padding: const EdgeInsets.only(left: 16, right: 16),
                    ),
                    SizedBox(
                      width: SizeConfig.screenWidth,
                      child: SignUpButton(
                        withSkipButton: false,
                        loading: notifier.isLoading,
                        onTap: notifier.onVerifyButton(context),
                        caption: notifier.language.verify ?? '',
                        textStyle: notifier.verifyTextColor(context),
                        buttonColor: notifier.verifyButtonColor(context),
                      ),
                    )
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
