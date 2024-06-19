import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class DescFaceVerification extends StatelessWidget {
  const DescFaceVerification({super.key});

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
            textToDisplay: System().bodyMultiLang(bodyEn: 'Face Verification', bodyId: 'Verifikasi Wajah') ?? '',
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
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
                    System().bodyMultiLang(bodyEn: 'Selfie Photo', bodyId: 'Foto Selfie') ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                twentyFourPx,
                const Center(
                  child: CustomIconWidget(
                    defaultColor: false,
                    iconData: "${AssetPath.vectorPath}face-verification.svg",
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                unorderedList(
                  System().bodyMultiLang(bodyEn: 'Photos taken directly from the phone`s camera.', bodyId: 'Foto diambil langsung dari kamera ponsel.') ?? '',
                ),
                unorderedList(
                  System().bodyMultiLang(bodyEn: 'Take photos without facial accessories.', bodyId: 'Ambil foto tanpa aksesoris wajah.') ?? '',
                ),
                unorderedList(
                  System().bodyMultiLang(
                          bodyEn: 'Make sure the photo is taken facing forward with sufficient lighting.', bodyId: 'Pastikan foto diambil menghadap ke depan dengan pencahayaan yang cukup.') ??
                      '',
                ),
                unorderedList(
                  System().bodyMultiLang(bodyEn: 'Do not move during the selfie.', bodyId: 'Jangan bergerak saat selfie.') ?? '',
                ),
                unorderedList(
                  System().bodyMultiLang(bodyEn: 'Make sure the photo is taken without flash and is not cropped.', bodyId: 'Pastikan foto diambil tanpa flash dan tidak terpotong.') ?? '',
                ),
                Text(notifier.language.uploadIdCardNotice8 ?? ''),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: CustomElevatedButton(
            width: SizeConfig.screenWidth,
            height: 44.0 * SizeConfig.scaleDiagonal,
            function: () => Routing().moveAndPop(Routes.cameraSelfieVerification),
            buttonStyle: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
              shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
              overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
            ),
            child: CustomTextWidget(
              textToDisplay: notifier.language.openCamera ?? '',
              textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
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
