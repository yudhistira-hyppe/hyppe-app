import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:camera/camera.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class CameraDevicesNotifier extends LoadingNotifier with ChangeNotifier {
  static final _system = System();

  String? _iOSVersion;
  CameraController? cameraController;
  List<CameraDescription> camera = [];
  FlashMode flashMode = FlashMode.off;
  NativeDeviceOrientation? orientation;

  bool get isInitialized => cameraController?.value.isInitialized ?? false;
  bool get isRecordingVideo => cameraController?.value.isRecordingVideo ?? false;
  bool get isRecordingPaused => cameraController?.value.isRecordingPaused ?? false;
  bool get isTakingPicture => cameraController?.value.isTakingPicture ?? false;
  bool get hasError => cameraController?.value.hasError ?? false;
  double get cameraAspectRatio => cameraController!.value.previewSize!.height / cameraController!.value.previewSize!.width;
  double get yScale => 1;

  // Object Key
  static const String loadingForSwitching = 'loadingForSwitching';

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  Future<void> initCamera(BuildContext context, bool mounted, {bool backCamera = false}) async {
    try {
      flashMode = FlashMode.off;

      camera = await availableCameras();

      cameraController = CameraController(
        backCamera ? camera[0] : camera[1],
        ResolutionPreset.veryHigh,
        enableAudio: true,
      );

      await cameraController?.initialize();

      if (Platform.isIOS) {
        await cameraController?.lockCaptureOrientation();
      }
      await cameraController?.setFlashMode(flashMode);
    } on CameraException catch (e) {
      e.description.logger();
    }
    if (!mounted) {
      return;
    }
    notifyListeners();
  }

  Future<void> onStoryPhotoVideo(bool isPhoto) async {
    final _currentLensDirection = cameraController?.description.lensDirection;

    if (cameraController != null) {
      await disposeCamera();
      notifyListeners();
    }

    final CameraController _controller = CameraController(
      _currentLensDirection == CameraLensDirection.back ? camera[0] : camera[1],
      _configureResolutionPreset(onStoryIsPhoto: isPhoto),
      enableAudio: true,
    );
    cameraController = _controller;

    // If the controller is updated then update the UI.
    cameraController?.addListener(() {
      notifyListeners();

      if (cameraController?.value.hasError ?? true) {
        'Camera error ${cameraController?.value.errorDescription}'.logger();
      }
    });

    try {
      await cameraController?.initialize();

      /// TODO: Resolved by backend
      if (Platform.isIOS) {
        await cameraController?.lockCaptureOrientation();
      }
      flashMode = cameraController!.value.flashMode;
    } on CameraException catch (e) {
      e.description.logger();
    }

    if (loadingForObject(loadingForSwitching)) {
      setLoading(false, loadingObject: loadingForSwitching);
    } else {
      notifyListeners();
    }
  }

  Future<void> onNewCameraSelected() async {
    final _currentLensDirection = cameraController?.description.lensDirection;

    if (cameraController != null) {
      await disposeCamera();
      notifyListeners();
    }

    final CameraController _controller = CameraController(
      _currentLensDirection == CameraLensDirection.back ? camera[1] : camera[0],
      _configureResolutionPreset(),
      enableAudio: true,
    );
    cameraController = _controller;

    // If the controller is updated then update the UI.
    cameraController?.addListener(() {
      notifyListeners();

      if (cameraController?.value.hasError ?? true) {
        'Camera error ${cameraController?.value.errorDescription}'.logger();
      }
    });

    try {
      await cameraController?.initialize();

      /// TODO: Resolved by backend
      // await cameraController?.lockCaptureOrientation();
      flashMode = cameraController!.value.flashMode;
    } on CameraException catch (e) {
      e.description.logger();
    }

    if (loadingForObject(loadingForSwitching)) {
      setLoading(false, loadingObject: loadingForSwitching);
    } else {
      notifyListeners();
    }
  }

  disposeCamera() async {
    try {
      'Disposing camera...'.logger();
      if (isRecordingVideo) {
        'Stop video recording...'.logger();
        await stopVideoRecording();
        'Success stop video recording...'.logger();
      }
      await cameraController?.dispose();
      cameraController = null;
      'Dispose camera success...'.logger();
    } catch (e) {
      e.logger();
    }
  }

  Future<void> prepareCameraPage() async {
    try {
      await availableCameras().then((value) => camera = value);
      if (Platform.isIOS) await _system.getIosInfo().then((value) => _iOSVersion = value.systemVersion);
    } catch (e) {
      e.logger();
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
    if (flashMode == FlashMode.off) {
      flashMode = FlashMode.auto;
    } else if (flashMode == FlashMode.auto) {
      flashMode = FlashMode.always;
    } else {
      flashMode = FlashMode.off;
    }
    flashMode.logger();
    notifyListeners();

    try {
      await cameraController?.setFlashMode(flashMode);
      notifyListeners();
    } on CameraException catch (e) {
      'CameraException => ${e.description}'.logger();
    }
  }

  String flashIcon() {
    if (flashMode == FlashMode.off) {
      return "${AssetPath.vectorPath}flash-off.svg";
    } else if (flashMode == FlashMode.auto) {
      return "${AssetPath.vectorPath}flash-auto.svg";
    } else {
      return "${AssetPath.vectorPath}flash.svg";
    }
  }

  Future<XFile?> takePicture() async {
    XFile _result;
    if (!isInitialized) {
      return null;
    }

    if (isTakingPicture) {
      return null;
    }

    try {
      _result = await cameraController!.takePicture();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return null;
    }
    return _result;
  }

  Future<void> startVideoRecording() async {
    if (!isInitialized) {
      return;
    }

    if (isRecordingVideo) {
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!isRecordingVideo) {
      return null;
    }

    try {
      final _xFile = await cameraController!.stopVideoRecording();
      notifyListeners();
      return _xFile;
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
}
