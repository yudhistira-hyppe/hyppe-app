import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';

class VerificationIDStep1 extends StatefulWidget {
  const VerificationIDStep1({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep1> createState() => _VerificationIDStep1State();
}

class _VerificationIDStep1State extends State<VerificationIDStep1> {
  final ScrollController _controller = ScrollController();
  String dataText = '';
  bool agree = false;
  bool finishScroll = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ntfr = Provider.of<VerificationIDNotifier>(context, listen: false);
      ntfr.clearAllTempData();
      ntfr.isSupportDoc = false;
      readFile();
      try {
        _controller.addListener(() {
          if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
            setState(() {
              finishScroll = true;
            });
          } else {
            if (finishScroll) {
              setState(() {
                agree = false;
                finishScroll = false;
              });
            }
          }
        });
      } catch (e) {
        print("error $e");
      }
      FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDStep1');
    });
  }

  readFile() async {
    String? isoCode = SharedPreference().readStorage(SpKeys.isoCode) ?? 'en';

    var request = await rootBundle.loadString('${AssetPath.dummyMdPath}eula_kyc_$isoCode.md');
    setState(() {
      dataText = request;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.userAgreement ?? '',
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          child: Column(children: [
            // Html(
            //   data: eulaHtml(context, (SharedPreference().readStorage(SpKeys.themeData) ?? false)),
            // ),
            // Container(
            //   color: Colors.red,
            //   height: SizeConfig.screenHeight! - 50,
            //   child:
            Markdown(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              data: dataText,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 220, top: 16),
              onTapLink: (text, href, title) async {
                try {
                  await launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication);
                } catch (e) {
                  // 'error href : $e'.logger();
                }
              },
            ),
            // ),

            // Expanded(
            //   child: InAppWebView(
            //     initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(supportZoom: false)),
            //     initialUrlRequest: URLRequest(url: Uri.parse("http://localhost:8080/assets/eula.html")),
            //     onWebViewCreated: (_controller) {},
            //     onLoadStart: (_controller, url) {},
            //     onLoadStop: (_controller, url) {},
            //   ),
            // )
          ]),
        ),
        bottomSheet: Container(
          // height: 120 * SizeConfig.scaleDiagonal,
          // padding: const EdgeInsets.only(left: 16, right: 16),
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              sixteenPx,

              Container(
                padding: const EdgeInsets.only(left: 6, right: 16, bottom: 16),
                child: Row(
                  children: [
                    Checkbox(
                        value: agree,
                        onChanged: (value) {
                          if (finishScroll) {
                            setState(() {
                              agree = value ?? false;
                            });
                          }
                        },
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.orange.withOpacity(.32);
                          }
                          if (!agree) {
                            return Colors.white;
                          }
                          return kHyppePrimary;
                        })),
                    sixPx,
                    Expanded(
                        child: Text(
                      notifier.language.userAgreementCheck ?? '',
                      style: const TextStyle(fontSize: 12),
                    ))
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: CustomElevatedButton(
                  width: SizeConfig.screenWidth,
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  function: () {
                    if (finishScroll && agree) {
                      Routing().moveAndPop(Routes.verificationIDStep2);
                    }
                  },
                  buttonStyle: finishScroll && agree
                      ? ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                        )
                      : ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                          shadowColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                          overlayColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                          backgroundColor: MaterialStateProperty.all(const Color(0xFFCECECE)),
                        ),
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.agreeAndContinue ?? '',
                    textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // GestureDetector(
              //   onTap: () => Routing().moveBack(),
              //   child: Text(
              //     notifier.language.cancel ?? 'cancel',
              //     style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // thirtyTwoPx,
            ],
          ),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // resizeToAvoidBottomInset: true,
      ),
    );
  }

  Row euloPoint({required String point, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(point), Expanded(child: Text(text))],
    );
  }
}
