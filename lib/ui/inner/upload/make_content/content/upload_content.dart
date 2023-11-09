import 'dart:io';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera/screen.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/screen.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/widget/build_capture_icon.dart';
import 'package:hyppe/ui/inner/upload/make_content/widget/build_storage.dart';
import 'package:hyppe/ui/inner/upload/make_content/widget/build_switch_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadContent extends StatelessWidget {
  final MakeContentNotifier? notifier;
  final bool? mounted;
  const UploadContent({Key? key, this.notifier, this.mounted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    print("===== candepp $canDeppAr");
    return canDeppAr == 'true'
        ? CameraDevicesPage(
            onCameraNotifierUpdate: (cameraNotifier) => notifier?.cameraDevicesNotifier = cameraNotifier,
            onChangeAppLifecycleState: () => notifier?.cancelVideoRecordingWhenAppIsPausedOrInactive(),
            additionalViews: <Widget>[
              // Camera / Video
              Align(alignment: Alignment.bottomCenter, child: BuildSwitchButton()),
              // Flash button
              if (Platform.isAndroid)
                SafeArea(
                  child: Visibility(
                    visible: !(notifier?.isRecordingVideo ?? true),
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
                            onTap: (){
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
              SafeArea(
                top: Platform.isIOS,
                child: Visibility(
                  visible: notifier?.conditionalOnClose() ?? false,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomTextButton(
                      onPressed: (notifier?.conditionalOnClose() ?? false) ? () async => await notifier?.onClose(context) : null,
                      child: const UnconstrainedBox(
                        child: CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg", defaultColor: false),
                      ),
                    ),
                  ),
                ),
              ),
              // Timer
              // Visibility(
              //   visible: !(notifier?.isRecordingVideo ?? true),
              //   child: Align(
              //     alignment: const Alignment(0.0, 0.63),
              //     child: BuildTimer(),
              //   ),
              // ),
              // Action
              Align(
                alignment: const Alignment(0.0, 0.75),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!(notifier?.isRecordingVideo ?? true)) Expanded(flex: 2, child: BuildStorage(mounted: mounted)),
                    Expanded(flex: 4, child: BuildCaptureIcon(mounted: mounted)),
                    // if (Platform.isIOS && !(notifier?.isRecordingVideo ?? true))
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
                    // if (!(notifier?.isRecordingVideo ?? true))
                      Expanded(flex: Platform.isIOS ? 2 : 2, child: const CameraDevicesSwitchButton())
                  ],
                ),
              ),
              // Ok button
              // Visibility(
              //   visible: notifier?.conditionalShowingOkButton() ?? false,
              //   child: Align(
              //     alignment: const Alignment(0.77, 0.705),
              //     child: BuildOkButton(mounted: mounted ?? false),
              //   ),
              // ),
              // Widget modal, this is widget appear, if loading state is true
              (notifier?.isLoading ?? false)
                  ? Container(color: Colors.black54, width: SizeConfig.screenWidth, height: SizeConfig.screenHeight, child: const UnconstrainedBox(child: CustomLoading()))
                  : const SizedBox.shrink()
            ],
          )
        : CameraPage(
            onCameraNotifierUpdate: (cameraNotifier) => notifier?.cameraNotifier = cameraNotifier,
            onChangeAppLifecycleState: () => notifier?.cancelVideoRecordingWhenAppIsPausedOrInactive(),
            additionalViews: <Widget>[
              // Camera / Video
              Align(alignment: Alignment.bottomCenter, child: BuildSwitchButton()),
              // Flash button
              if (Platform.isAndroid)
                SafeArea(
                  child: Visibility(
                    visible: !(notifier?.isRecordingVideo ?? true),
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
                            onTap: (){
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
              SafeArea(
                top: Platform.isIOS,
                child: Visibility(
                  visible: notifier?.conditionalOnClose() ?? false,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomTextButton(
                      onPressed: (notifier?.conditionalOnClose() ?? false) ? () async => await notifier?.onClose(context) : null,
                      child: const UnconstrainedBox(
                        child: CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg", defaultColor: false),
                      ),
                    ),
                  ),
                ),
              ),
              // Timer
              // Visibility(
              //   visible: !(notifier?.isRecordingVideo ?? true),
              //   child: Align(
              //     alignment: const Alignment(0.0, 0.63),
              //     child: BuildTimer(),
              //   ),
              // ),
              // Action
              Align(
                alignment: const Alignment(0.0, 0.75),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 2, child: !(notifier?.isRecordingVideo ?? true) ? BuildStorage(mounted: mounted) : const SizedBox.shrink()),
                    // if (!(notifier?.isRecordingVideo ?? true)) Expanded(flex: 1, child: BuildEffect(mounted: mounted, isRecord: notifier?.isRecordingVideo ?? false)),
                    Expanded(flex: 2, child: BuildCaptureIcon(mounted: mounted)),
                    if (Platform.isIOS && !(notifier?.isRecordingVideo ?? true))
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CameraFlashButton(),
                            CustomTextWidget(
                              textToDisplay: context.watch<TranslateNotifierV2>().translate.flash!,
                              textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                            ),
                          ],
                        ),
                      ),
                    // if (!(notifier?.isRecordingVideo ?? true))
                      Expanded(flex: Platform.isIOS ? 2 : 2, child: const CameraSwitchButton())
                  ],
                ),
              ),
              // Ok button
              // Visibility(
              //   visible: notifier?.conditionalShowingOkButton() ?? false,
              //   child: Align(
              //     alignment: const Alignment(0.77, 0.705),
              //     child: BuildOkButton(mounted: mounted ?? false),
              //   ),
              // ),
              // Widget modal, this is widget appear, if loading state is true
              (notifier?.isLoading ?? false)
                  ? Container(color: Colors.black54, width: SizeConfig.screenWidth, height: SizeConfig.screenHeight, child: const UnconstrainedBox(child: CustomLoading()))
                  : const SizedBox.shrink()
            ],
          );
  }
}
