import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_hovered_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
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
              ),
             
            ],
          ),
          twelvePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 1,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              twelvePx,
              CustomTextWidget(
                  textToDisplay: notifier.language.or!,
                  textStyle: Theme.of(context).textTheme.bodyText2),
              twelvePx,
              Container(
                width: 50,
                height: 1,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
          twelvePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                   final loginSign=Provider.of<LoginNotifier>(context,listen: false);
                  loginSign.loginGoogleSignIn(context);
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.secondary),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Image(
                      image: AssetImage('${AssetPath.pngPath}logo_google.png')),
                ),
              ),
              twelvePx,
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Image(
                    image: AssetImage('${AssetPath.pngPath}logo_facebook.png')),
              ),
              twelvePx,
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Image(
                    image: AssetImage('${AssetPath.pngPath}logo_twitter.png')),
              ),
              twelvePx,
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.secondary),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Image(
                    image: AssetImage('${AssetPath.pngPath}logo_apple.png')),
              )
            ],
          )
          // CustomHoveredButton(
          //   child:
          //       !notifier.loadingForObject(LoginNotifier.loadingLoginGoogleKey)
          //           ? CustomTextWidget(
          //               textToDisplay: "Continue using Google",
          //               textStyle: Theme.of(context).textTheme.button,
          //             )
          //           : CustomLoading(),
          //   width: MediaQuery.of(context).size.width,
          //   height: 50,
          //   function: () {
          //     if (!notifier
          //         .loadingForObject(LoginNotifier.loadingLoginGoogleKey)) {
          //       notifier.onClickGoogle(context);
          //     }
          //   },
          // )
        ],
      ),
    );
  }
}
