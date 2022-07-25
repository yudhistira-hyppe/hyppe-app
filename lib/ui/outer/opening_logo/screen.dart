import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/initial/hyppe/notifier.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

class OpeningLogo extends StatefulWidget {
  @override
  _OpeningLogoState createState() => _OpeningLogoState();
}

class _OpeningLogoState extends State<OpeningLogo> {
  @override
  void initState() {
    final _notifier = Provider.of<HyppeNotifier>(context, listen: false);
    Timer(const Duration(seconds: 2), () async => await _notifier.handleStartUp(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _textTheme = Theme.of(context).textTheme;
    bool _themeState = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            CustomIconWidget(
              defaultColor: false,
              iconData: _themeState ? '${AssetPath.vectorPath}logo.svg' : '${AssetPath.vectorPath}logo_splash_screem.svg',
            ),
            Column(
              children: [
                CustomIconWidget(
                  defaultColor: false,
                  iconData: _themeState ? '${AssetPath.vectorPath}logo_kemendag_kominfo-white.svg' : '${AssetPath.vectorPath}logo_kemendag_kominfo.svg',
                ),
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    style: _textTheme.bodyText2,
                    text: 'Hyppe telah terdaftar di ',
                    children: [
                      TextSpan(
                        text: 'Kemendag',
                        // recognizer: TapGestureRecognizer()..onTap = () => notifier.goToEula(),
                        style: _textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: ' & ',
                            style: _textTheme.bodyText2,
                            children: [
                              TextSpan(
                                text: ' Kominfo ',
                                // recognizer: TapGestureRecognizer()..onTap = () => context.read<UserInterestNotifier>().goToEula(),
                                style: _textTheme.bodyText2?.copyWith(fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
      // body: Center(
      //   child: CustomIconWidget(
      //     defaultColor: false,
      //     iconData: '${AssetPath.vectorPath}logo_splash_screem.svg',
      //   ),
      // ),
    );
  }
}
