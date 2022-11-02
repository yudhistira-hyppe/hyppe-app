import 'dart:io';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/entities/camera/screen.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_flash_button.dart';
// import 'package:hyppe/ui/constant/entities/camera/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/widget/build_capture_icon.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class UploadIDVerification extends StatelessWidget {
  final MakeContentNotifier? notifier;
  final bool? mounted;

  const UploadIDVerification({
    Key? key,
    this.notifier,
    this.mounted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CameraPage(
      onCameraNotifierUpdate: (cameraNotifier) =>
          notifier?.cameraNotifier = cameraNotifier,
      additionalViews: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            height: SizeConfig.screenHeight ?? context.getHeight() * 0.07,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.44),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ),
        SafeArea(
          top: Platform.isIOS,
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextButton(
                    onPressed: !(notifier?.isRecordingVideo ?? true)
                        ? () async {
                            debugPrint("DONE_BACK");
                            notifier?.isVideo = false;
                            Routing().moveBack();
                          }
                        : null,
                    child: const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}close.svg",
                        defaultColor: false)),
                CustomTextWidget(
                  textToDisplay: "ID Card",
                  textStyle: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: SizeConfig.screenHeight ?? context.getHeight() / 5,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0.0, 0.9),
          child: BuildCaptureIcon(mounted: mounted),
        ),
        // TODO: Add a camera switch button
        // Align(
        //   alignment: const Alignment(0.65, 0.85),
        //   child: CameraSwitchButton(),
        // ),
        const Align(
          alignment: Alignment(-0.65, 0.85),
          child: CameraFlashButton(),
        ),
        // Align(
        //   alignment: const Alignment(0.0, -0.45),
        //   child: Container(
        //     width: 203,
        //     height: 259,
        //     decoration: BoxDecoration(image: DecorationImage(image: AssetImage("${AssetPath.pngPath}circle-face.png"))),
        //   ),
        // ),
        const Align(
          // alignment: const Alignment(0.0, 0.40),
          alignment: Alignment.center,
          child: CustomIconWidget(
            iconData: "${AssetPath.vectorPath}card.svg",
            defaultColor: false,
            height: 183,
            width: 281,
          ),
        ),
      ],
    );
  }
}
