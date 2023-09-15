import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_bottom.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/page_top.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:move_to_background/move_to_background.dart';

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {
  TextEditingController endpoint = TextEditingController();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'WelcomeLoginScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: GestureDetector(
        child: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                width: SizeConfig.screenWidth,
                child: Column(
                  children: [
                    const PageTop(),
                    PageBottom(),
                    // testLogin(),
                    // formEndpoint(),
                  ],
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          if (!FocusScope.of(context).hasPrimaryFocus) FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget testLogin() {
    return GestureDetector(
      onTap: () {
        Routing().move(Routes.testLogin);
      },
      child: Text('Testlogin'),
    );
  }

  Widget formEndpoint() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CustomTextFormField(
            inputAreaHeight: 55 * SizeConfig.scaleDiagonal,
            inputAreaWidth: SizeConfig.screenWidth!,
            textEditingController: endpoint,
            style: Theme.of(context).textTheme.bodyText1,
            textInputType: TextInputType.emailAddress,
            inputDecoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              labelText: "End point test ",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface)),
            ),
          ),
          twelvePx,
          CustomElevatedButton(
              width: SizeConfig.screenWidth!,
              height: 50,
              function: () {
                SharedPreference().writeStorage(SpKeys.endPointTest, endpoint.text);
                print("${SharedPreference().readStorage(SpKeys.endPointTest)}");
              },
              buttonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(kHyppePrimary),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Text("Simpan end point")),
        ],
      ),
    );
  }
}
