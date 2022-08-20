import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/camera/screen.dart';
import 'package:hyppe/ui/constant/entities/camera/widgets/camera_flash_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
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

    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Scaffold(
        body: CameraPage(
          onCameraNotifierUpdate: (cameraNotifier) =>
              notifier.cameraNotifier = cameraNotifier,
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
                        onPressed: () => notifier.clearAndMoveToLobby(),
                        child: const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}close.svg",
                            defaultColor: false)),
                    CustomTextWidget(
                      textToDisplay: "ID Verification",
                      textStyle:
                          textTheme.subtitle1?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, 0.9),
              child: CustomIconButtonWidget(
                  iconData: "${AssetPath.vectorPath}shutter.svg",
                  onPressed: () => notifier.onTakePicture(context)),
            ),
            const Align(
              alignment: Alignment(0.8, 0.9),
              child: CameraFlashButton(),
            ),
            const Align(
              alignment: Alignment.center,
              child: CustomIconWidget(
                iconData: "${AssetPath.vectorPath}card.svg",
                defaultColor: false,
                height: 183,
                width: 281,
              ),
            ),
            Align(
              alignment: const Alignment(0.0, 0.6),
              child: CustomTextWidget(
                  textToDisplay: "Place your KTP within the frame",
                  textStyle:
                      textTheme.subtitle1?.copyWith(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
