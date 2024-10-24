import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class VerificationIDStep3 extends StatefulWidget {
  const VerificationIDStep3({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep3> createState() => _VerificationIDStep3State();
}

class _VerificationIDStep3State extends State<VerificationIDStep3>
    with AfterFirstLayoutMixin {
  late CameraDevicesNotifier notifier;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDStep3');
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    notifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    notifier.initCamera(context, mounted);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 *
              (SizeConfig.screenWidth ?? context.getWidth()) /
              SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.idVerification ?? '',
            textStyle:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                twentyFourPx,
                Center(
                  child: Text(
                    notifier.language.ektpPhoto ?? 'E-KTP Photo',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                twentyFourPx,
                const Center(
                  child: CustomIconWidget(
                    defaultColor: false,
                    iconData: "${AssetPath.vectorPath}ektpphoto.svg",
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                unorderedList(notifier.language.uploadIdCardNotice1 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice2 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice3 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice4 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice5 ?? ''),
                unorderedList(notifier.language.uploadIdCardNotice6 ?? ''),
                // unorderedList(notifier.language.uploadIdCardNotice7 ?? ''),
                // unorderedList(notifier.language.uploadIdCardNotice8 ?? ''),
                const SizedBox(
                  height: 20,
                ),
                Text(notifier.language.uploadIdCardNotice8 ?? ''),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 44.0 * SizeConfig.scaleDiagonal,
            function: () => Routing().moveAndPop(Routes.verificationIDStep4),
            buttonStyle: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              shadowColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              overlayColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
            ),
            child: CustomTextWidget(
              textToDisplay: notifier.language.openCamera ?? '',
              textStyle:
                  textTheme.labelLarge?.copyWith(color: kHyppeLightButtonText),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget unorderedList(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text("• "), Expanded(child: Text(text))],
      ),
    );
  }
}
