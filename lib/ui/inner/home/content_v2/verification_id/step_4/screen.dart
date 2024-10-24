import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/screen.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:provider/provider.dart';

class VerificationIDStep4 extends StatefulWidget {
  const VerificationIDStep4({Key? key}) : super(key: key);

  @override
  State<VerificationIDStep4> createState() => _VerificationIDStep4State();
}

class _VerificationIDStep4State extends State<VerificationIDStep4>
    with RouteAware {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VerificationIDStep4');

    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.retryTakeIdCard();
          return false;
        },
        child: Scaffold(
            body: CameraDevicesPage(
          onCameraNotifierUpdate: (cameraNotifier) =>
              notifier.cameraDevicesNotifier = cameraNotifier,
          backCamera: true,
          additionalViews: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                height: SizeConfig.screenHeight! * 0.07,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.44),
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
                        onPressed: () => notifier.retryTakeIdCard(),
                        child: const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}close.svg",
                            defaultColor: false)),
                    CustomTextWidget(
                      textToDisplay: notifier.language.idVerification ?? '',
                      textStyle:
                          textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            // Align(
            //   alignment: const Alignment(-0.8, 0.8),
            //   child: CameraSwitchButton(),
            // ),
            OverlayWithRectangleClipping(),
            Align(
              alignment: const Alignment(0.0, 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                    width: 90,
                    // color: Colors.red,
                  ),
                  SizedBox(
                      height: 105 * SizeConfig.scaleDiagonal,
                      width: 105 * SizeConfig.scaleDiagonal,
                      child: CustomIconButtonWidget(
                        iconData: "${AssetPath.vectorPath}shutter.svg",
                        onPressed: () => notifier.onTakePicture(context),
                      )),
                  const SizedBox(width: 90, child: CameraDevicesFlashButton()),
                ],
              ),
            ),

            // const Align(
            //   alignment: Alignment.center,
            //   child: CustomIconWidget(
            //     iconData: "${AssetPath.vectorPath}card.svg",
            //     defaultColor: false,
            //     height: 183,
            //     width: 281,
            //   ),
            // ),
            Align(
              alignment: const Alignment(0.0, 0.6),
              child: CustomTextWidget(
                  textToDisplay: notifier.language.cameraTakeIdCardInfo ?? '',
                  textStyle:
                      textTheme.titleMedium?.copyWith(color: Colors.white)),
            ),
          ],
        )

            // canDeppAr == 'true' || Platform.isIOS
            //     ? CameraDevicesPage(
            //         onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraDevicesNotifier = cameraNotifier,
            //         backCamera: true,
            //         additionalViews: <Widget>[
            //           Align(
            //             alignment: Alignment.topCenter,
            //             child: Container(
            //               width: double.infinity,
            //               height: SizeConfig.screenHeight! * 0.07,
            //               decoration: BoxDecoration(
            //                 gradient: LinearGradient(
            //                   begin: Alignment.topCenter,
            //                   end: Alignment.bottomCenter,
            //                   colors: [
            //                     Theme.of(context).colorScheme.background.withOpacity(0.44),
            //                     Colors.transparent,
            //                   ],
            //                 ),
            //                 borderRadius: const BorderRadius.only(
            //                   topLeft: Radius.circular(8),
            //                   topRight: Radius.circular(8),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SafeArea(
            //             top: Platform.isIOS,
            //             child: Align(
            //               alignment: Alignment.topLeft,
            //               child: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   CustomTextButton(onPressed: () => notifier.retryTakeIdCard(), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false)),
            //                   CustomTextWidget(
            //                     textToDisplay: notifier.language.idVerification ?? '',
            //                     textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           // Align(
            //           //   alignment: const Alignment(-0.8, 0.8),
            //           //   child: CameraSwitchButton(),
            //           // ),
            //           Align(
            //             alignment: const Alignment(0.0, 0.9),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 const SizedBox(
            //                   height: 10,
            //                   width: 90,
            //                   // color: Colors.red,
            //                 ),
            //                 SizedBox(
            //                     height: 105 * SizeConfig.scaleDiagonal,
            //                     width: 105 * SizeConfig.scaleDiagonal,
            //                     child: CustomIconButtonWidget(
            //                       iconData: "${AssetPath.vectorPath}shutter.svg",
            //                       onPressed: () => notifier.onTakePicture(context),
            //                     )),
            //                 const SizedBox(width: 90, child: CameraFlashButton()),
            //               ],
            //             ),
            //           ),

            //           const Align(
            //             alignment: Alignment.center,
            //             child: CustomIconWidget(
            //               iconData: "${AssetPath.vectorPath}card.svg",
            //               defaultColor: false,
            //               height: 183,
            //               width: 281,
            //             ),
            //           ),
            //           Align(
            //             alignment: const Alignment(0.0, 0.6),
            //             child: CustomTextWidget(textToDisplay: notifier.language.cameraTakeIdCardInfo ?? '', textStyle: textTheme.titleMedium?.copyWith(color: Colors.white)),
            //           )
            //         ],
            //       )
            //     : CameraPage(
            //         onCameraNotifierUpdate: (cameraNotifier) => notifier.cameraNotifier = cameraNotifier,
            //         backCamera: true,
            //         additionalViews: <Widget>[
            //           Align(
            //             alignment: Alignment.topCenter,
            //             child: Container(
            //               width: double.infinity,
            //               height: SizeConfig.screenHeight! * 0.07,
            //               decoration: BoxDecoration(
            //                 gradient: LinearGradient(
            //                   begin: Alignment.topCenter,
            //                   end: Alignment.bottomCenter,
            //                   colors: [
            //                     Theme.of(context).colorScheme.background.withOpacity(0.44),
            //                     Colors.transparent,
            //                   ],
            //                 ),
            //                 borderRadius: const BorderRadius.only(
            //                   topLeft: Radius.circular(8),
            //                   topRight: Radius.circular(8),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           SafeArea(
            //             top: Platform.isIOS,
            //             child: Align(
            //               alignment: Alignment.topLeft,
            //               child: Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   CustomTextButton(onPressed: () => notifier.retryTakeIdCard(), child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}close.svg", defaultColor: false)),
            //                   CustomTextWidget(
            //                     textToDisplay: notifier.language.idVerification ?? '',
            //                     textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           // Align(
            //           //   alignment: const Alignment(-0.8, 0.8),
            //           //   child: CameraSwitchButton(),
            //           // ),
            //           Align(
            //             alignment: const Alignment(0.0, 0.9),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 const SizedBox(
            //                   height: 10,
            //                   width: 90,
            //                   // color: Colors.red,
            //                 ),
            //                 SizedBox(
            //                     height: 105 * SizeConfig.scaleDiagonal,
            //                     width: 105 * SizeConfig.scaleDiagonal,
            //                     child: CustomIconButtonWidget(
            //                       iconData: "${AssetPath.vectorPath}shutter.svg",
            //                       onPressed: () => notifier.onTakePicture(context),
            //                     )),
            //                 const SizedBox(width: 90, child: CameraFlashButton()),
            //               ],
            //             ),
            //           ),

            //           const Align(
            //             alignment: Alignment.center,
            //             child: CustomIconWidget(
            //               iconData: "${AssetPath.vectorPath}card.svg",
            //               defaultColor: false,
            //               height: 183,
            //               width: 281,
            //             ),
            //           ),
            //           Align(
            //             alignment: const Alignment(0.0, 0.6),
            //             child: CustomTextWidget(textToDisplay: notifier.language.cameraTakeIdCardInfo ?? '', textStyle: textTheme.titleMedium?.copyWith(color: Colors.white)),
            //           )
            //         ],
            //       ),
            ),
      ),
    );
  }
}

class OverlayWithRectangleClipping extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: _getCustomPaintOverlay(context));
  }

  //CustomPainter that helps us in doing this
  CustomPaint _getCustomPaintOverlay(BuildContext context) {
    return CustomPaint(
        size: MediaQuery.of(context).size, painter: RectanglePainter());
  }
}

class RectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    canvas.drawPath(
        Path.combine(
          PathOperation.difference, //simple difference of following operations
          //bellow draws a rectangle of full screen (parent) size
          Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
          //bellow clips out the circular rectangle with center as offset and dimensions you need to set
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset(size.width * 0.5, size.height * 0.5),
                    width: size.width * 0.90,
                    height: size.height * 0.25),
                Radius.circular(15),
              ),
            )
            ..close(),
        ),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
