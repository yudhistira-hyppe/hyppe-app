import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/initial/hyppe/notifier.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import '../../inner/main/notifier.dart';

class OpeningLogo extends StatefulWidget {
  final bool isLaunch;
  const OpeningLogo({Key? key, this.isLaunch = true}) : super(key: key);

  @override
  _OpeningLogoState createState() => _OpeningLogoState();
}

class _OpeningLogoState extends State<OpeningLogo> with AfterFirstLayoutMixin {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OpeningLogo');
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    SharedPreference().removeValue(SpKeys.uploadContent);
    if (widget.isLaunch) {
      context.read<MainNotifier>().pageIndex = 3;
      final notifier = Provider.of<HyppeNotifier>(context, listen: false);
      Future.delayed(const Duration(seconds: 2), () {
        notifier.handleStartUp(mounted);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _textTheme = Theme.of(context).textTheme;
    bool _themeState =
        SharedPreference().readStorage(SpKeys.themeData) ?? false;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            CustomIconWidget(
              defaultColor: false,
              iconData: _themeState
                  ? '${AssetPath.vectorPath}logo.svg'
                  : '${AssetPath.vectorPath}logo_splash_screem.svg',
            ),
            Column(
              children: [
                CustomIconWidget(
                  defaultColor: false,
                  iconData: _themeState
                      ? '${AssetPath.vectorPath}logo_kemendag_kominfo-white.svg'
                      : '${AssetPath.vectorPath}logo_kemendag_kominfo.svg',
                ),
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    style: _textTheme.bodyMedium,
                    text: 'Hyppe telah terdaftar di ',
                    children: [
                      TextSpan(
                        text: 'Kemendag',
                        // recognizer: TapGestureRecognizer()..onTap = () => notifier.goToEula(),
                        style: _textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: ' & ',
                            style: _textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: 'Kominfo ',
                                // recognizer: TapGestureRecognizer()..onTap = () => context.read<UserInterestNotifier>().goToEula(),
                                style: _textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
