import 'dart:io';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';

class CameraNotifier extends LoadingNotifier with ChangeNotifier {
  static final _system = System();
  DeepArController? deepArController;
  String? _iOSVersion;
  CameraController? cameraController;
  List<CameraDescription> camera = [];
  FlashMode flashMode = FlashMode.off;
  NativeDeviceOrientation? orientation;

  bool get isInitialized => deepArController?.isInitialized ?? false;
  bool get isRecordingVideo => deepArController?.isRecording ?? false;
  bool get isRecordingPaused => deepArController?.isRecording ?? false;
  bool get isTakingPicture => cameraController?.value.isTakingPicture ?? false;
  bool get hasError => cameraController?.value.hasError ?? false;
  double get cameraAspectRatio => deepArController!.imageDimensions.height / deepArController!.imageDimensions.width;
  double get yScale => 1;

  bool _showEffected = false;
  bool get showEffected => _showEffected;

  set showEffected(bool val) {
    _showEffected = val;
    notifyListeners();
  }

  // Object Key
  static const String loadingForSwitching = 'loadingForSwitching';

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  Future<void> initCamera(BuildContext context, bool mounted) async {
    // print('DeepAR: initCamera, mounted: ');print(mounted);
    try {
      final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
      flashMode = FlashMode.off;
      deepArController = DeepArController();
      if (Platform.isAndroid) {
        deepArController!.destroy();
      }
      await deepArController!
          .initialize(
        androidLicenseKey: "2a5a8cfda693ae38f2e20925295b950b13f0a7c186dcd167b5997655932d82ceb0cbc27be4c0b513",
        iosLicenseKey: "6389e21310378b39591d7a24897a1f59456ce3c5cf0fbf89033d535438d2f1cf10ea4829b25cf117 ",
        resolution: _configureResolutionDeepArPreset(onStoryIsPhoto: notifier.featureType == FeatureType.story ? !notifier.isVideo : null),
      )
          .then((value) {
        print('DeepAR: DeepAR done initialized');
      });

      // cameraController = CameraController(
      //   camera[0],
      //   _configureResolutionPreset(onStoryIsPhoto: notifier.featureType == FeatureType.story ? !notifier.isVideo : null),
      //   enableAudio: true,
      // );

      // await cameraController?.initialize();

      // if (Platform.isIOS) {
      //   await cameraController?.lockCaptureOrientation();
      // }
      // await cameraController?.setFlashMode(flashMode);
    } on CameraException catch (e) {
      e.description.logger();
    }
    if (!mounted) {
      return;
    }
    notifyListeners();
  }

  Future<void> onStoryPhotoVideo(bool isPhoto) async {
    if (deepArController!.isRecording) {
      // File? file = await _controller.stopVideoRecording();
      // OpenFile.open(file.path);
    } else {
      await deepArController!.startVideoRecording();
    }

    // final _currentLensDirection = cameraController?.description.lensDirection;

    // if (cameraController != null) {
    //   await disposeCamera();
    //   notifyListeners();
    // }

    // final CameraController _controller = CameraController(
    //   _currentLensDirection == CameraLensDirection.back ? camera[0] : camera[1],
    //   _configureResolutionPreset(onStoryIsPhoto: isPhoto),
    //   enableAudio: true,
    // );
    // cameraController = _controller;

    // // If the controller is updated then update the UI.
    // cameraController?.addListener(() {
    //   notifyListeners();

    //   if (cameraController?.value.hasError ?? true) {
    //     'Camera error ${cameraController?.value.errorDescription}'.logger();
    //   }
    // });

    // try {
    //   await cameraController?.initialize();

    //   /// TODO: Resolved by backend
    //   if (Platform.isIOS) {
    //     await cameraController?.lockCaptureOrientation();
    //   }
    //   flashMode = cameraController!.value.flashMode;
    // } on CameraException catch (e) {
    //   e.description.logger();
    // }

    if (loadingForObject(loadingForSwitching)) {
      setLoading(false, loadingObject: loadingForSwitching);
    } else {
      notifyListeners();
    }
  }

  Future<void> onNewCameraSelected() async {
    print('DeepAR: balik kamera');
    deepArController!.flipCamera();
  }

  disposeCamera() async {
    try {
      if (Platform.isAndroid) {
        deepArController = DeepArController();
        deepArController = null;
      }
      deepArController!.destroy();
      deepArController = null;
    } catch (e) {
      e.logger();
    }
    /////yg lama
    // try {
    //   'Disposing camera...'.logger();
    //   if (isRecordingVideo) {
    //     'Stop video recording...'.logger();
    //     await stopVideoRecording();
    //     'Success stop video recording...'.logger();
    //   }
    //   await cameraController?.dispose();
    //   cameraController = null;
    //   'Dispose camera success...'.logger();
    // } catch (e) {
    //   e.logger();
    // }
  }

  Future<void> prepareCameraPage() async {
    try {
      await availableCameras().then((value) => camera = value);
      if (Platform.isIOS) await _system.getIosInfo().then((value) => _iOSVersion = value.systemVersion);
    } catch (e) {
      e.logger();
    }
  }

  Resolution _configureResolutionDeepArPreset({bool? onStoryIsPhoto}) {
    if (Platform.isIOS && int.parse(_iOSVersion!.replaceAll('.', '')) <= minIphoneVersionForResolutionCamera) {
      return Resolution.high;
    } else {
      return onStoryIsPhoto != null && onStoryIsPhoto == true ? Resolution.veryHigh : Resolution.high;
    }
  }

  ResolutionPreset _configureResolutionPreset({bool? onStoryIsPhoto}) {
    if (Platform.isIOS && int.parse(_iOSVersion!.replaceAll('.', '')) <= minIphoneVersionForResolutionCamera) {
      return ResolutionPreset.high;
    } else {
      return onStoryIsPhoto != null && onStoryIsPhoto == true ? ResolutionPreset.veryHigh : ResolutionPreset.max;
    }
  }

  Future<void> onFlashButtonPressed() async {
    deepArController!.toggleFlash();
  }

  String flashIcon() {
    if (deepArController != null && deepArController!.flashState) {
      return "${AssetPath.vectorPath}flash-off.svg";
    } else if (flashMode == FlashMode.auto) {
      return "${AssetPath.vectorPath}flash-auto.svg";
    } else {
      return "${AssetPath.vectorPath}flash.svg";
    }
  }

  Future<File?> takePicture() async {
    File _result;
    File? _result2;
    if (!isInitialized) {
      return null;
    }

    if (isTakingPicture) {
      return null;
    }

    try {
      await deepArController!.takeScreenshot().then((file) {
        _result2 = file;

        // OpenFile.open(file.path);
      });
      _result = _result2!;

      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return null;
    }
    return _result;
  }

  Future<void> startVideoRecording() async {
    print('play video');
    if (!isInitialized) {
      return;
    }

    if (isRecordingVideo) {
      return;
    }

    try {
      await deepArController!.startVideoRecording();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return;
    }
  }

  Future<File?> stopVideoRecording() async {
    if (!isRecordingVideo) {
      return null;
    }

    try {
      File? file = await deepArController!.stopVideoRecording();
      // final _xFile = await cameraController!.stopVideoRecording();
      notifyListeners();
      return file;
    } on CameraException catch (e) {
      e.logger();
      return null;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (cameraController == null || !isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.resumeVideoRecording();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (cameraController == null || !isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.pauseVideoRecording();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return;
    }
  }

  void showEffect() {
    print('DeepAR: Show Effect');
    _showEffected = !_showEffected;
    notifyListeners();
  }
}
