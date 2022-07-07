import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/button_sosmed.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/login/notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/notifier.dart';
import 'package:hyppe/ui/outer/welcome_login/widget/register.dart';
import 'package:provider/provider.dart';

class PageBottom extends StatefulWidget {
  @override
  _PageBottomState createState() => _PageBottomState();
}

class _PageBottomState extends State<PageBottom> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeLoginNotifier>(
      builder: (_, notifier, __) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 34, 16, 34),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  CustomTextWidget(
                    textToDisplay: 'Selamat Datang di Hyppe',
                    textStyle: Theme.of(context).primaryTextTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  eightPx,
                  CustomTextWidget(
                    textToDisplay: 'Masuk untuk menemukan sesuatu yang menarik di aplikasi Hyppe',
                    maxLines: 2,
                    textStyle: Theme.of(context).primaryTextTheme.subtitle2!,
                  ),
                  fortyTwoPx,
                  ButtomSosmed(
                    function: () => notifier.loginGoogleSign(context),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(right: 15.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFFEDEDED),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: CustomIconWidget(
                            defaultColor: false,
                            iconData: '${AssetPath.vectorPath}google.svg',
                          ),
                        ),
                        const Spacer(),
                        CustomTextWidget(
                          textToDisplay: 'Masuk dengan akun Google',
                          textStyle: Theme.of(context).textTheme.subtitle2!,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  twelvePx,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ),
                      ),
                      twelvePx,
                      CustomTextWidget(textToDisplay: notifier.language.or!, textStyle: Theme.of(context).textTheme.bodyText2),
                      twelvePx,
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  twelvePx,
                  ButtomSosmed(
                    function: () {
                      notifier.onClickLoginEmail();
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          padding: EdgeInsets.only(right: 15.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFFEDEDED),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: CustomIconWidget(
                            defaultColor: false,
                            iconData: '${AssetPath.vectorPath}person.svg',
                          ),
                        ),
                        const Spacer(),
                        CustomTextWidget(
                          textToDisplay: 'Gunakan alamat Email lainnya',
                          textStyle: Theme.of(context).textTheme.subtitle2!,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  twelvePx,
                ],
              ),
              Register(),
            ],
          ),
        ),
      ),
    );
  }
}
