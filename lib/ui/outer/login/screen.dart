import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:hyppe/ui/outer/login/widget/sign_in_form.dart';
import 'package:hyppe/ui/outer/login/widget/sign_in_text.dart';
import 'package:hyppe/ui/outer/login/widget/sign_up_or_google.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LoginScreen');
    SizeConfig().init(context);
    return GestureDetector(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<LoginNotifier>(
                builder: (_, notifier, __) => Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: GestureDetector(
                              onTap: () => notifier.tapBack(),
                              child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg'),
                            ),
                          ),

                          /// *****JANGAN DIHAPUS*****
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 30),
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          //     decoration: BoxDecoration(border: Border.all(color: kHyppeLightSecondary, width: 1.0), borderRadius: const BorderRadius.all(Radius.circular(5))),
                          //     child: GestureDetector(
                          //       onTap: () async {
                          //         await notifier.goToHelpLogin(context);
                          //       },
                          //       child: CustomTextWidget(
                          //         textToDisplay: notifier.language.help ?? 'Help',
                          //         textStyle: Theme.of(context).primaryTextTheme.bodyText1?.copyWith(fontSize: 14),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    thirtySixPx,
                    Align(alignment: const Alignment(0.0, -0.85), child: SignInText()),
                    sixtyFourPx,
                    SignInForm(),
                    sixtyFourPx,
                    const SignUpOrGoogle(),
                  ],
                ),
              ),
            ),
          ),
        ),
        // floatingActionButton: Selector<LoginNotifier, bool>(
        //     builder: (_, value, __) {
        //       return Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           Text('Prod Mode'),
        //           Checkbox(
        //             checkColor: Colors.white,
        //             activeColor: Colors.purple,
        //             value: value,
        //             onChanged: (v) => context.read<LoginNotifier>().baseEnv = v!,
        //           ),
        //         ],
        //       );
        //     },
        //     selector: (_, selector) => selector.baseEnv),
      ),
      onTap: () {
        if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
      },
    );
  }
}
