import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/provider_widget.dart';
import 'package:flutter/material.dart';

import '../../../../../ux/routing.dart';

class CameraFlashButton extends ProviderWidget<CameraNotifier> {
  const CameraFlashButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, notifier) {
    return GestureDetector(
      onDoubleTap: null,
      child: CustomTextButton(
        onPressed: () => notifier.onFlashButtonPressed(Routing.navigatorKey.currentContext ?? context),
        child: CustomIconWidget(
          defaultColor: false,
          iconData: notifier.flashIcon(),
        ),
      ),
    );
  }
}
