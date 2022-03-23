import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/upload/preview_content/widget/build_any_content_preview.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewIDVerification extends StatelessWidget {
  final String? picture;
  final PageController pageController;

  const PreviewIDVerification({
    Key? key,
    this.picture,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: BuildAnyContentPreviewer(
            pageController: pageController,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: SizeConfig.screenHeight! * 0.07,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(-0.7, 0.97),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth! * 0.05),
            child: Consumer<AccountPreferencesNotifier>(
              builder: (_, notifier, __) => Row(
                // TODO: Need to be refactored, waiting for the new design
                // mainAxisAlignment: notifier.picIDVerification == null || !System().validateUrl(notifier.picIDVerification!)
                //     ? MainAxisAlignment.spaceBetween
                //     : MainAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // if (notifier.picIDVerification == null || !System().validateUrl(notifier.picIDVerification!))
                  CustomTextButton(
                    onPressed: () {
                      // Routing().moveAndPop(makeContent);
                      Routing().moveBack();
                    },
                    child: Row(
                      children: [
                        const CustomIconWidget(iconData: "${AssetPath.vectorPath}camera.svg", defaultColor: false),
                        const SizedBox(width: 8),
                        CustomTextWidget(textToDisplay: notifier.language.retake!, textStyle: Theme.of(context).textTheme.subtitle1),
                      ],
                    ),
                  ),
                  // TODO: Need to be refactored, waiting for the new design
                  // notifier.picIDVerification != null && notifier.picIDVerification!.isNotEmpty
                  //     ? CustomTextButton(
                  //         onPressed: () => Routing().moveBack(),
                  //         child: Row(
                  //           children: [
                  //             CustomTextWidget(textToDisplay: notifier.language.close!, textStyle: Theme.of(context).textTheme.subtitle1),
                  //             SizedBox(width: 8),
                  //             CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false),
                  //           ],
                  //         ),
                  //       )
                  //     : CustomTextButton(
                  //         onPressed: () async => await notifier.onUploadProofPicture(context, picture),
                  //         child: Row(
                  //           children: [
                  //             CustomTextWidget(textToDisplay: notifier.language.upload!, textStyle: Theme.of(context).textTheme.subtitle1),
                  //             SizedBox(width: 8),
                  //             CustomIconWidget(iconData: "${AssetPath.vectorPath}arrow.svg", defaultColor: false),
                  //           ],
                  //         ),
                  //       ),
                  CustomTextButton(
                    onPressed: () async => await notifier.onUploadProofPicture(context, picture),
                    child: Row(
                      children: [
                        CustomTextWidget(textToDisplay: notifier.language.upload!, textStyle: Theme.of(context).textTheme.subtitle1),
                        const SizedBox(width: 8),
                        const CustomIconWidget(iconData: "${AssetPath.vectorPath}arrow.svg", defaultColor: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
