import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/provider_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../ux/routing.dart';

class CameraSwitchButton extends ProviderWidget<CameraNotifier> {
  const CameraSwitchButton({Key? key}) : super(key: key, reactive: false);

  @override
  Widget build(BuildContext context, notifier) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onDoubleTap: (){
        print('data camera doubleTap');
        // notifier.setLoading(true, loadingObject: CameraNotifier.loadingForSwitching);
        Future.delayed(const Duration(milliseconds: 250), () => notifier.onNewCameraSelected(Routing.navigatorKey.currentContext ?? context));
      },
      onTap: () {
        print('data camera ontap');
        // notifier.setLoading(true, loadingObject: CameraNotifier.loadingForSwitching);
        Future.delayed(const Duration(milliseconds: 250), () => notifier.onNewCameraSelected(Routing.navigatorKey.currentContext ?? context));
      },
      child: const CustomIconWidget(
        defaultColor: false,
        iconData: "${AssetPath.vectorPath}flip.svg",
      ),
    );
  }
}
