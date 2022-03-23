import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = context.watch<CameraNotifier>();
    final deviceRatio = SizeConfig.screenWidth! / SizeConfig.screenHeight!;

    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        final orientation = NativeDeviceOrientationReader.orientation(context);
        'Received new orientation: $orientation'.logger();
        'Received new converted orientation: ${System().convertOrientation(orientation)}'.logger();

        'Current device orientation: ${notifier.orientation}'.logger();

        if (notifier.isRecordingVideo && notifier.orientation == null) {
          notifier.orientation = orientation;
          'Set orientation to $orientation'.logger();
          'Set orientation to ${System().convertOrientation(orientation)}'.logger();
        }

        return Container(
          child: AspectRatio(
            aspectRatio: deviceRatio,
            child: Transform(
              alignment: Alignment.center,
              child: CameraPreview(notifier.cameraController!),
              transform: Matrix4.diagonal3Values(notifier.cameraAspectRatio / deviceRatio, notifier.yScale.toDouble(), 1),
            ),
          ),
        );
      },
    );
  }
}

/**
 * // return Transform.scale(
    //   scale: (notifier.cameraController!.value.previewSize!.height / notifier.cameraController!.value.previewSize!.width) /
    //       (SizeConfig.screenWidth! / SizeConfig.screenHeight!),
    //   child: Center(
    //     child: AspectRatio(
    //       aspectRatio: (notifier.cameraController!.value.previewSize!.height / notifier.cameraController!.value.previewSize!.width),
    //       child: CameraPreview(notifier.cameraController!),
    //     ),
    //   ),
    // );
 */
