import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/camera/screen.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/screen.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:provider/provider.dart';

class VerificationIDStep6 extends StatefulWidget {
  const VerificationIDStep6({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep6> createState() => _VerificationIDStep6State();
}

class _VerificationIDStep6State extends State<VerificationIDStep6> with RouteAware {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {}

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.backFromSelfie(context);
          return true;
        },
        child: Scaffold(
          body: CameraDevicesPage(
            onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraDevicesNotifier = cameraNotifier,
            additionalViews: <Widget>[
              SafeArea(
                top: Platform.isIOS,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextButton(onPressed: () => notifier.backFromSelfie(context), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false)),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0.0, 0.75),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 4, child: const CameraFlashButton()),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 105 * SizeConfig.scaleDiagonal,
                        child: CustomIconButtonWidget(
                          iconData: "${AssetPath.vectorPath}photo.svg",
                          onPressed: () => notifier.onTakeSelfie(context),
                        ),
                      ),
                    ),
                    Expanded(flex: 4, child: const CameraSwitchButton())
                  ],
                ),
              ),
              if (notifier.isLoading)
                Container(
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: kHyppePrimary,
                      ),
                      SizedBox(height: 10),
                      ProcessUploadComponent(),
                    ],
                  ),
                )
            ],
          ),
          //  canDeppAr == 'true'
          //     ? CameraDevicesPage(
          //         onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraDevicesNotifier = cameraNotifier,
          //         additionalViews: <Widget>[
          //           SafeArea(
          //             top: Platform.isIOS,
          //             child: Align(
          //               alignment: Alignment.topLeft,
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   CustomTextButton(onPressed: () => notifier.backFromSelfie(context), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false)),
          //                 ],
          //               ),
          //             ),
          //           ),
          //           Align(
          //             alignment: const Alignment(0.0, 0.75),
          //             child: Row(
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               children: [
          //                 Expanded(flex: 4, child: const CameraFlashButton()),
          //                 Expanded(
          //                   flex: 4,
          //                   child: SizedBox(
          //                     height: 105 * SizeConfig.scaleDiagonal,
          //                     child: CustomIconButtonWidget(
          //                       iconData: "${AssetPath.vectorPath}photo.svg",
          //                       onPressed: () => notifier.onTakeSelfie(context),
          //                     ),
          //                   ),
          //                 ),
          //                 Expanded(flex: 4, child: const CameraSwitchButton())
          //               ],
          //             ),
          //           ),
          //           if (notifier.isLoading)
          //             Container(
          //               width: SizeConfig.screenWidth,
          //               height: SizeConfig.screenHeight,
          //               color: Colors.white,
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.center,
          //                 children: const [
          //                   CircularProgressIndicator(
          //                     color: kHyppePrimary,
          //                   ),
          //                   SizedBox(height: 10),
          //                   ProcessUploadComponent(),
          //                 ],
          //               ),
          //             )
          //         ],
          //       )
          //     : CameraPage(
          //         onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraNotifier = cameraNotifier,
          //         additionalViews: <Widget>[
          //           SafeArea(
          //             top: Platform.isIOS,
          //             child: Align(
          //               alignment: Alignment.topLeft,
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   CustomTextButton(onPressed: () => notifier.backFromSelfie(context), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false)),
          //                 ],
          //               ),
          //             ),
          //           ),
          //           Align(
          //             alignment: const Alignment(0.0, 0.75),
          //             child: Row(
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               children: [
          //                 Expanded(flex: 4, child: const CameraFlashButton()),
          //                 Expanded(
          //                   flex: 4,
          //                   child: SizedBox(
          //                       height: 105 * SizeConfig.scaleDiagonal, child: CustomIconButtonWidget(iconData: "${AssetPath.vectorPath}photo.svg", onPressed: () => notifier.onTakeSelfie(context))),
          //                 ),
          //                 Expanded(flex: 4, child: const CameraSwitchButton())
          //               ],
          //             ),
          //           ),
          //           if (notifier.isLoading)
          //             Container(
          //               width: SizeConfig.screenWidth,
          //               height: SizeConfig.screenHeight,
          //               color: Colors.white,
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 crossAxisAlignment: CrossAxisAlignment.center,
          //                 children: const [
          //                   CircularProgressIndicator(
          //                     color: kHyppePrimary,
          //                   ),
          //                   SizedBox(height: 10),
          //                   ProcessUploadComponent(),
          //                 ],
          //               ),
          //             )
          //         ],
          //       ),
        ),
      ),
    );
  }
}
