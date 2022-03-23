import 'package:flutter/material.dart' show BuildContext;

/// Camera Interface
abstract class CameraInterface {
  void onStopRecordedVideo(BuildContext context) {}

  void onRecordedVideo(BuildContext context) {}

  void onPauseRecordedVideo(BuildContext context) {}

  void onResumeRecordedVideo(BuildContext context) {}

  void onTakePicture(BuildContext context) {}

  bool get hasError => false;

  bool get isInitialized => false;

  bool get isRecordingPaused => false;

  bool get isRecordingVideo => false;

  bool get isTakingPicture => false;
}