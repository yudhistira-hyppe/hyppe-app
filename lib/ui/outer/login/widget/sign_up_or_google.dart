import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpOrGoogle extends StatelessWidget {
  const SignUpOrGoogle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(
      builder: (_, notifier, __) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextWidget(
                textToDisplay: "${notifier.language.dontHaveAnAccount!}?   ",
                textStyle: Theme.of(context).primaryTextTheme.bodyText2,
              ),
              GestureDetector(
                onTap: () => notifier.onClickSignUpHere(),
                child: CustomTextWidget(
                  textToDisplay: notifier.language.registerHere!,
                  textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primaryVariant,
                      ),
                ),
              )
            ],
          ),
          // twelvePx,
          // CustomTextWidget(textToDisplay: notifier.language.or!, textStyle: Theme.of(context).textTheme.bodyText2),
          // twelvePx,
          // CustomHoveredButton(
          //   child: !notifier.loadingForObject(LoginNotifier.loadingLoginGoogleKey)
          //       ? CustomTextWidget(
          //           textToDisplay: "Continue using Google",
          //           textStyle: Theme.of(context).textTheme.button,
          //         )
          //       : CustomLoading(),
          //   width: MediaQuery.of(context).size.width,
          //   height: 50,
          //   function: () {
          //     if (!notifier.loadingForObject(LoginNotifier.loadingLoginGoogleKey)) {
          //       notifier.onClickGoogle(context);
          //     }
          //   },
          // )
        ],
      ),
    );
  }
}
