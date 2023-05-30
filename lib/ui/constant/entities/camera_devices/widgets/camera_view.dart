import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';

class CameraDevicesView extends StatelessWidget {
  const CameraDevicesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = context.watch<CameraDevicesNotifier>();
    final deviceRatio = SizeConfig.screenWidth! / SizeConfig.screenHeight!;

    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (context) {
        final orientation = NativeDeviceOrientationReader.orientation(context);
        'Received new orientation: $orientation'.logger();
        'Received new converted orientation: ${System().convertOrientation(orientation)}'
            .logger();

        'Current device orientation: ${notifier.orientation}'.logger();

        if (notifier.isRecordingVideo && notifier.orientation == null) {
          notifier.orientation = orientation;
          'Set orientation to $orientation'.logger();
          'Set orientation to ${System().convertOrientation(orientation)}'
              .logger();
        }

        return Builder(builder: (context) {

          if (notifier.cameraController != null) {
            final sizeRatio = notifier.cameraController!.value.previewSize;
            return sizeRatio != null ? AspectRatio(
              aspectRatio: deviceRatio,
              child: Transform(
                alignment: Alignment.center,
                child: CameraPreview(notifier.cameraController!), //for camera

                transform: Matrix4.diagonal3Values(
                    notifier.cameraAspectRatio / deviceRatio,
                    notifier.yScale.toDouble(),
                    1),
              ),
            ): const SizedBox.shrink();
          } else {
            return const SizedBox.shrink();
          }


        });
      },
    );
  }
}
