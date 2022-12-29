import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/eula.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationIDStepSupportDocsEula extends StatefulWidget {
  const VerificationIDStepSupportDocsEula({Key? key}) : super(key: key);

  @override
  State<VerificationIDStepSupportDocsEula> createState() => _VerificationIDStepSupportDocsEulaState();
}

class _VerificationIDStepSupportDocsEulaState extends State<VerificationIDStepSupportDocsEula> {
  String dataText = '';

  @override
  void initState() {
    readFile();
    super.initState();
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
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.backToVerificationID();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => notifier.backToVerificationID(),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier.language.idVerification ?? '',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              // Html(
              //   data: eulaHtml(context, (SharedPreference().readStorage(SpKeys.themeData) ?? false)),
              // ),
              SizedBox(
                height: SizeConfig.screenHeight,
                child: Markdown(
                  data: dataText,
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 220, top: 16),
                  onTapLink: (text, href, title) async {
                    try {
                      print('markdown  $text, $href, $title');
                      await launchUrl(Uri.parse(text), mode: LaunchMode.externalApplication);
                    } catch (e) {
                      // 'error href : $e'.logger();
                    }
                  },
                ),
              ),

              // Expanded(
              //   child: InAppWebView(
              //     initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(supportZoom: false)),
              //     initialUrlRequest: URLRequest(url: Uri.parse("http://localhost:8080/assets/eula.html")),
              //     onWebViewCreated: (controller) {},
              //     onLoadStart: (controller, url) {},
              //     onLoadStop: (controller, url) {},
              //   ),
              // )
            ]),
          ),
          floatingActionButton: Container(
            height: 140 * SizeConfig.scaleDiagonal,
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  width: SizeConfig.screenWidth,
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  function: () => Routing().moveAndPop(Routes.verificationIDStepSupportingDocs),
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.agreeAndContinue ?? '',
                    textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                  ),
                  buttonStyle: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => notifier.backToVerificationID(),
                  child: Text(
                    notifier.language.cancel ?? '',
                    style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          resizeToAvoidBottomInset: true,
        ),
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
