import 'dart:io';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera/screen.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/screen.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/widget/build_capture_icon.dart';
import 'package:hyppe/ui/inner/upload/make_content/widget/build_storage.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../constant/entities/camera_devices/notifier.dart';

class UploadContent extends StatelessWidget {
  final MakeContentNotifier notifier;
  final bool? mounted;
  const UploadContent({Key? key, required this.notifier, this.mounted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    return canDeppAr == 'true'
        ? CameraDevicesPage(
            onDoubleTap: () {
              final camera = context.read<CameraDevicesNotifier>();
              camera.setLoading(true, loadingObject: CameraDevicesNotifier.loadingForSwitching);
              Future.delayed(const Duration(milliseconds: 1000), () => camera.onNewCameraSelected());
            },
            onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraDevicesNotifier = cameraNotifier,
            onChangeAppLifecycleState: () => notifier.cancelVideoRecordingWhenAppIsPausedOrInactive(),
            additionalViews: <Widget>[
              /// Camera / Video
              // Align(alignment: Alignment.bottomCenter, child: BuildSwitchButton()),
              /// Flash button
              if (!notifier.conditionalCaptureVideoIcon())
                SafeArea(
                  child: Visibility(
                    visible: !notifier.isRecordingVideo,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: [
                          const CameraDevicesFlashButton(),
                          CustomTextWidget(
                            textToDisplay: context.watch<TranslateNotifierV2>().translate.flash!,
                            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                          ),
                          tenPx,
                          GestureDetector(
                            onTap: () {
                              context.read<CameraNotifier>().showEffect();
                            },
                            child: const CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}ic_effect.svg",
                            ),
                          ),
                          CustomTextWidget(
                            textToDisplay: context.watch<TranslateNotifierV2>().translate.effect!,
                            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Close button
              if (!notifier.conditionalCaptureVideoIcon())
                SafeArea(
                  top: Platform.isIOS,
                  child: Visibility(
                    visible: notifier.conditionalOnClose(),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextButton(
                        onPressed: notifier.conditionalOnClose() ? () async => await notifier.onClose(context) : null,
                        child: const UnconstrainedBox(
                          child: CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg", defaultColor: false),
                        ),
                      ),
                    ),
                  ),
                ),
              if (notifier.showToast)
                Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          width: context.getWidth() * 0.7,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kHyppeTextLightPrimary),
                          child: CustomTextWidget(
                            textToDisplay: notifier.messageToast,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
              // Timer
              // Visibility(
              //   visible: !(notifier.isRecordingVideo ?? true),
              //   child: Align(
              //     alignment: const Alignment(0.0, 0.63),
              //     child: BuildTimer(),
              //   ),
              // ),
              // Action
              if (notifier.conditionalCaptureVideoIcon())
                Builder(builder: (context) {
                  final tempDuration = Duration(seconds: notifier.elapsedProgress);
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        margin: EdgeInsets.only(top: Platform.isIOS ? 60 : 10),
                        child: CustomTextWidget(
                          textToDisplay: tempDuration.formatter(),
                          textStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                        )),
                  );
                }),
              Align(
                alignment: const Alignment(0.0, 0.9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!notifier.isRecordingVideo)
                      Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [BuildStorage(mounted: mounted), fortyPx],
                          )),
                    BuildCaptureIcon(mounted: mounted),
                    // if (Platform.isIOS && !(notifier.isRecordingVideo ?? true))
                    //   Expanded(
                    //     flex: 1,
                    //     child: Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         // const CameraFlashButton(),
                    //         CustomTextWidget(
                    //           textToDisplay: context.watch<TranslateNotifierV2>().translate.flash!,
                    //           textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // if (!(notifier.isRecordingVideo ?? true))
                    const Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            fortyPx,
                            CameraDevicesSwitchButton(),
                          ],
                        ))
                  ],
                ),
              ),
              // Ok button
              // Visibility(
              //   visible: notifier.conditionalShowingOkButton() ?? false,
              //   child: Align(
              //     alignment: const Alignment(0.77, 0.705),
              //     child: BuildOkButton(mounted: mounted ?? false),
              //   ),
              // ),
              // Widget modal, this is widget appear, if loading state is true
              notifier.isLoading
                  ? Container(color: Colors.black54, width: SizeConfig.screenWidth, height: SizeConfig.screenHeight, child: const UnconstrainedBox(child: CustomLoading()))
                  : const SizedBox.shrink()
            ],
          )
        : CameraPage(
            onDoubleTap: () {
              print('data camera doubletap');
              final camera = context.read<CameraNotifier>();
              // camera.setLoading(true, loadingObject: CameraDevicesNotifier.loadingForSwitching);
              Future.delayed(const Duration(milliseconds: 1000), () => camera.onNewCameraSelected(Routing.navigatorKey.currentContext ?? context));
              // Future.delayed(const Duration(milliseconds: 250), () => camera.onNewCameraSelected());
            },
            onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraNotifier = cameraNotifier,
            onChangeAppLifecycleState: () => notifier.cancelVideoRecordingWhenAppIsPausedOrInactive(),
            additionalViews: <Widget>[
              // Camera / Video
              // Align(alignment: Alignment.bottomCenter, child: BuildSwitchButton()),
              // Flash button
              if (!notifier.conditionalCaptureVideoIcon())
                SafeArea(
                  child: Visibility(
                    visible: !notifier.isRecordingVideo,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: [
                          const CameraFlashButton(),
                          CustomTextWidget(
                            textToDisplay: context.watch<TranslateNotifierV2>().translate.flash!,
                            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                          ),
                          tenPx,
                          GestureDetector(
                            onTap: () {
                              // context.read<CameraNotifier>().showEffect();
                              ShowBottomSheet.onShowEffect(context: context, whenComplete: () {});
                            },
                            child: const CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}ic_effect.svg",
                            ),
                          ),
                          CustomTextWidget(
                            textToDisplay: context.watch<TranslateNotifierV2>().translate.effect!,
                            textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Close button
              if (!notifier.conditionalCaptureVideoIcon())
                SafeArea(
                  top: Platform.isIOS,
                  child: Visibility(
                    visible: notifier.conditionalOnClose(),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CustomTextButton(
                        onPressed: notifier.conditionalOnClose() ? () async => await notifier.onClose(context) : null,
                        child: const UnconstrainedBox(
                          child: CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg", defaultColor: false),
                        ),
                      ),
                    ),
                  ),
                ),
              if (notifier.showToast)
                Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          width: context.getWidth() * 0.7,
                          // height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: kHyppeTextLightPrimary),
                          child: CustomTextWidget(
                            textToDisplay: notifier.messageToast,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
              // Timer
              // Visibility(
              //   visible: !(notifier.isRecordingVideo ?? true),
              //   child: Align(
              //     alignment: const Alignment(0.0, 0.63),
              //     child: BuildTimer(),
              //   ),
              // ),
              // Action
              if (notifier.conditionalCaptureVideoIcon())
                Builder(builder: (context) {
                  final tempDuration = Duration(seconds: notifier.elapsedProgress);
                  return SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          margin: EdgeInsets.only(top: Platform.isIOS ? 60 : 10),
                          child: CustomTextWidget(
                            textToDisplay: tempDuration.formatter(),
                            textStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                          )),
                    ),
                  );
                }),
              Align(
                alignment: const Alignment(0.0, 0.9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 2,
                        child: !notifier.isRecordingVideo
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [BuildStorage(mounted: mounted), fortyPx],
                              )
                            : const SizedBox.shrink()),
                    // if (!(notifier.isRecordingVideo ?? true)) Expanded(flex: 1, child: BuildEffect(mounted: mounted, isRecord: notifier.isRecordingVideo ?? false)),
                    BuildCaptureIcon(mounted: mounted),
                    // if (Platform.isIOS && !(notifier.isRecordingVideo ?? true))
                    //   Expanded(
                    //     flex: 1,
                    //     child: Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         const CameraFlashButton(),
                    //         CustomTextWidget(
                    //           textToDisplay: context.watch<TranslateNotifierV2>().translate.flash!,
                    //           textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // if (!(notifier.isRecordingVideo ?? true))
                    const Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            fortyPx,
                            CameraSwitchButton(),
                          ],
                        ))
                  ],
                ),
              ),
              // Ok button
              // Visibility(
              //   visible: notifier.conditionalShowingOkButton() ?? false,
              //   child: Align(
              //     alignment: const Alignment(0.77, 0.705),
              //     child: BuildOkButton(mounted: mounted ?? false),
              //   ),
              // ),
              // Widget modal, this is widget appear, if loading state is true
              notifier.isLoading
                  ? Container(color: Colors.black54, width: SizeConfig.screenWidth, height: SizeConfig.screenHeight, child: const UnconstrainedBox(child: CustomLoading()))
                  : const SizedBox.shrink()
            ],
          );
  }
}
