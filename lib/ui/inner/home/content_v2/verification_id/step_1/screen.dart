import 'package:flutter/material.dart';
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: notifier.language.endUserLicenseAgreement!,
                  textStyle: textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 8,
                ),
                CustomTextWidget(
                  textToDisplay: notifier.language.aboutIdVerification!,
                  textStyle: textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 16,
                ),
                euloPoint(
                    point: "1. ",
                    text:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
                euloPoint(
                    point: "2. ",
                    text:
                        "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"),
                euloPoint(
                    point: "3. ",
                    text:
                        "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"),
                const SizedBox(
                  height: 150,
                ),
              ],
            ),
          ),
        ),
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
