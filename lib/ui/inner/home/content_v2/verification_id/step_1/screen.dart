import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStep1 extends StatefulWidget {
  const VerificationIDStep1({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep1> createState() => _VerificationIDStep1State();
}

class _VerificationIDStep1State extends State<VerificationIDStep1> {
  @override
  void initState() {
    final ntfr = Provider.of<VerificationIDNotifier>(context, listen: false);
    ntfr.clearAllTempData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.idVerification!,
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Container(
            child: Column(children: <Widget>[
          Expanded(
            child: InAppWebView(
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(supportZoom: false)),
              initialUrlRequest: URLRequest(
                  url: Uri.parse("http://localhost:8080/assets/eula.html")),
              onWebViewCreated: (controller) {},
              onLoadStart: (controller, url) {},
              onLoadStop: (controller, url) {},
            ),
          )
        ])),
        floatingActionButton: Container(
          height: 140 * SizeConfig.scaleDiagonal,
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Routing().moveBack(),
                child: Text(
                  notifier.language.cancel!,
                  style: textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primaryVariant),
                ),
              ),
              const SizedBox(height: 16),
              CustomElevatedButton(
                width: SizeConfig.screenWidth,
                height: 44.0 * SizeConfig.scaleDiagonal,
                function: () =>
                    Routing().moveAndPop(Routes.verificationIDStep2),
                child: CustomTextWidget(
                  textToDisplay: notifier.language.agreeAndContinue!,
                  textStyle:
                      textTheme.button?.copyWith(color: kHyppeLightButtonText),
                ),
                buttonStyle: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  shadowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  overlayColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primaryVariant),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: true,
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
