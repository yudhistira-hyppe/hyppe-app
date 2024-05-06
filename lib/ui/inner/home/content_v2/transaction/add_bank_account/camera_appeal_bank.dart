import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/screen.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/widgets/camera_switch_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class CameraAppealBank extends StatefulWidget {
  const CameraAppealBank({Key? key}) : super(key: key);

  @override
  State<CameraAppealBank> createState() => _CameraAppealBankState();
}

class _CameraAppealBankState extends State<CameraAppealBank> with RouteAware {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'CameraAppealBank');
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    context.read<TransactionNotifier>().pickedSupportingDocs = [];
  }

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
    // final textTheme = Theme.of(context).textTheme;
    // final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    return Consumer<TransactionNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          // notifier.backFromSelfie(context);

          return true;
        },
        child: Scaffold(
          body: CameraDevicesPage(
            onCameraNotifierUpdate: (cameraNotifier) => cameraNotifier,
            additionalViews: <Widget>[
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextButton(
                        onPressed: () {
                          Routing().moveBack();
                        },
                        child: const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}back-arrow.svg",
                          defaultColor: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () {
                              notifier.onPickSupportedDocument(context, true);
                            },
                            child: const CustomIconWidget(
                              defaultColor: false,
                              iconData: "${AssetPath.vectorPath}ic_galery.svg",
                            ),
                          )),
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 105 * SizeConfig.scaleDiagonal,
                          child: CustomIconButtonWidget(
                            iconData: "${AssetPath.vectorPath}photo.svg",
                            onPressed: () => notifier.takePictSupport(context),
                          ),
                        ),
                      ),
                      Expanded(flex: 4, child: CameraDevicesSwitchButton())
                    ],
                  ),
                ),
              ),

              // if (notifier.isLoading)
              //   Container(
              //     width: SizeConfig.screenWidth,
              //     height: SizeConfig.screenHeight,
              //     color: Colors.white,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: const [
              //         CircularProgressIndicator(
              //           color: kHyppePrimary,
              //         ),
              //         SizedBox(height: 10),
              //         ProcessUploadComponent(),
              //       ],
              //     ),
              //   )
            ],
          ),
        ),
      ),
    );
  }
}
