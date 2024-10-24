import 'dart:async';
import 'dart:io';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/file_extension.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/create_post_response.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/camera_interface.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/entities/camera_devices/notifier.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../app.dart';

class MakeContentNotifier extends LoadingNotifier with ChangeNotifier implements CameraInterface {
  static final _routing = Routing();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  CameraNotifier cameraNotifier = CameraNotifier();
  CameraDevicesNotifier cameraDevicesNotifier = CameraDevicesNotifier();

  FeatureType? _featureType;
  String? _thumbnailImageLocal;

  FeatureType? get featureType => _featureType;
  String? get thumbnailImageLocal => _thumbnailImageLocal;

  Timer? _timer;
  double _progressDev = 0.0;
  final int _maxDuration = 60;
  Map<int, String>? _durationOptions;
  int _progressHuman = 0;
  int _elapsedProgress = 0;
  int _selectedDuration = 15;
  double _slider = 0;
  bool _isVideo = false;
  CreatePostResponse? _postModel;
  bool _showToast = false;

  double get progressDev => _progressDev;
  int get elapsedProgress => _elapsedProgress;
  int get progressHuman => _progressHuman;
  bool get isVideo => _isVideo;
  double get slider => _slider;
  Timer? get timer => _timer;
  CreatePostResponse? get postModel => _postModel;
  Map<int, String>? get durationOptions => _durationOptions;
  int get selectedDuration => _selectedDuration;
  bool get showToast => _showToast;

  set featureType(FeatureType? val) {
    _featureType = val;
    notifyListeners();
  }

  set elapsedProgress(int val) {
    _elapsedProgress = val;
    notifyListeners();
  }

  set selectedDuration(int val) {
    _selectedDuration = val;
    notifyListeners();
  }

  set isVideo(bool value) {
    _isVideo = value;
    notifyListeners();
  }

  set slider(double value) {
    _slider = value;
    notifyListeners();
  }

  set showToast(bool state) {
    _showToast = state;
    notifyListeners();
  }

  showVideoToast(Duration duration) {
    if (!showToast) {
      showToast = true;
      Future.delayed(duration, () {
        showToast = false;
      });
    }
  }

  String _messageToast = '';
  String get messageToast => _messageToast;
  set messageToast(String val) {
    _messageToast = val;
    notifyListeners();
  }

  onInitialUploadContent() {
    _selectedDuration = 15;

    // if (_featureType == FeatureType.vid) {
    //   _durationOptions = {
    //     15: "15${language.timerSecond}",
    //     30: "30${language.timerSecond}",
    //     60: "60${language.timerSecond}",
    //     0: "1m>"}; // ignore this
    // } else if (_featureType == FeatureType.diary) {
    //   _durationOptions = {
    //     15: "15${language.timerSecond}",
    //     30: "30${language.timerSecond}",
    //     60: "60${language.timerSecond}",
    //   };
    // } else {
    //   _durationOptions = {
    //     15: "15${language.timerSecond}",
    //   };
    // }

    if (featureType == FeatureType.diary) {
      _selectedDuration = 60;
    } else if (featureType == FeatureType.vid) {
      _selectedDuration = 1800;
    } else if (featureType == FeatureType.story) {
      _selectedDuration = 15;
    }
    notifyListeners();
  }

  onActionChange(BuildContext context, bool photo) {
    isVideo = !photo;
    dynamic notifier;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    if (canDeppAr == 'true') {
      notifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    } else {
      notifier = Provider.of<CameraNotifier>(context, listen: false);
    }
    // notifier.setLoading(true, loadingObject: CameraNotifier.loadingForSwitching);
    Future.delayed(const Duration(milliseconds: 250), () => notifier.onStoryPhotoVideo(photo));
  }

  bool conditionalShowingOkButton() {
    if (featureType != FeatureType.pic && isRecordingVideo) {
      return isRecordingPaused || (progressHuman >= selectedDuration && selectedDuration != 0);
    } else {
      return isRecordingPaused;
    }
  }

  bool conditionalCaptureVideoIcon() {
    if (featureType != FeatureType.pic) {
      // return isRecordingVideo && !isRecordingPaused && (progressHuman < selectedDuration || selectedDuration == 0);
      return isRecordingVideo && (progressHuman < selectedDuration || selectedDuration == 0);
    } else {
      return isRecordingPaused;
    }
  }

  bool conditionalOnClose() {
    if (featureType != FeatureType.pic && isRecordingVideo) {
      return isRecordingPaused || (progressHuman >= selectedDuration && selectedDuration != 0);
    } else {
      return true;
    }
  }

  int carouselValueIndex() {
    if (_featureType == FeatureType.vid) {
      return selectedDuration == 15
          ? 0
          : selectedDuration == 30
              ? 1
              : selectedDuration == 60
                  ? 2
                  : 3;
    } else if (_featureType == FeatureType.diary) {
      return selectedDuration == 15
          ? 0
          : selectedDuration == 30
              ? 1
              : 2;
    } else {
      return 0;
    }
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer(BuildContext context) {
    _validateTimerWithFeature();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timerIn) {
        // check if user paused recording and then update the state
        // if (isRecordingPaused) {
        //   timerIn.cancel();
        //   cancelTimer();
        // }

        if (_timer != null && (_timer?.isActive ?? false) && timerIn.isActive) {
          _elapsedProgress++;
          if (featureType != FeatureType.pic && selectedDuration != 0) {
            _progressDev = _elapsedProgress / _selectedDuration;
          } else {
            _progressDev = 1.0;
          }
          _progressHuman += 1;
        }

        if (_progressHuman >= _selectedDuration && (featureType != FeatureType.vid || _selectedDuration != 0)) {
          // onPauseRecordedVideo(context);
          timerIn.cancel();
          cancelTimer();
        }
        notifyListeners();
        if (_progressHuman == _selectedDuration && (featureType != FeatureType.vid || _selectedDuration != 0)) {
          Future.delayed(const Duration(milliseconds: 500), () {
            onStopRecordedVideo(materialAppKey.currentContext ?? context);
          });
        }
      },
    );
  }

  void _validateTimerWithFeature() {
    if (featureType == FeatureType.story || featureType == FeatureType.diary) {
      if (_selectedDuration == 0) {
        _selectedDuration = _maxDuration;
      }
    }
  }

  Future onClose(BuildContext context) async {
    try {
      bool? _sheetResponse;
      if (isRecordingVideo) {
        _sheetResponse = await ShowBottomSheet().onShowColouredSheet(
          context,
          language.cancelRecording ?? '',
          color: kHyppeTextWarning,
        );
      }

      if (_sheetResponse == null || _sheetResponse) {
        if (isRecordingVideo) {
          await context.read<CameraNotifier>().stopVideoRecording(context);
          resetVariable(dispose: false);
        } else {
          resetVariable(dispose: true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _routing.moveBack();
          });
        }
      }
    } catch (e) {
      e.logger();
    }
  }

  void resetVariable({required bool dispose}) {
    if (dispose) _isVideo = false;
    cancelTimer();
    _progressDev = 0.0;
    _progressHuman = 0;
    _elapsedProgress = 0;
    if (!dispose) notifyListeners();
  }

  void thumbnailLocalMedia() async {
    String? _dir;
    List<String> _folderToSearch = ['/Pictures/', '/pictures/', '/DCIM/Camera/', '/Download/', '/download/', '/DCIM/', '/Camera/', '/Picture/', '/picture/'];
    if (Platform.isAndroid) {
      _thumbnailImageLocal = null;

      void _getFirstFile(FileSystemEntity element) {
        String _extFile = System().extensionFiles(element.absolute.path) as String;
        _extFile = _extFile.replaceAll('.', '');
        if (element is File && _extFile.endsWith(JPG) || _extFile.endsWith(JPEG) || _extFile.endsWith(PNG)) {
          _thumbnailImageLocal = element.absolute.path;
        }
      }

      var _directory = await getExternalStorageDirectory();

      // loop for move back to root
      for (int count = 0; count < 4; count++) {
        _dir = Directory(_dir ?? (_directory?.absolute.path ?? '')).parent.absolute.path;
      }

      // loop for get first file picture
      for (String folder in _folderToSearch) {
        if (_thumbnailImageLocal != null) break;
        if (Directory('$_dir$folder').existsSync()) Directory('$_dir$folder').listSync(recursive: true).forEach(_getFirstFile);
      }

      notifyListeners();
    }
  }

  void onTapOnFrameLocalMedia(BuildContext context) async {
    setLoading(true);
    try {
      print('isVideo $isVideo');

      await System()
          .getLocalMedia(
              featureType: featureType,
              context: context,
              isVideo: isVideo,
              onException: () {
                if (featureType == FeatureType.story) {
                  messageToast = language.messageLessLimitStory ?? 'Error';
                  showVideoToast(const Duration(seconds: 3));
                } else {
                  messageToast = language.messageLessLimitVideo ?? 'Error';
                  showVideoToast(const Duration(seconds: 3));
                }
              })
          .then((value) async {
        Future.delayed(const Duration(milliseconds: 1000), () async {
          if (value.values.single != null) {
            Future.delayed(const Duration(milliseconds: 1000), () => setLoading(false));
            final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
            notifier.fileContent = value.values.single?.map((e) => e.path).toList();

            final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
            if (canDeppAr == 'true') {
              notifier.aspectRation = context.read<CameraDevicesNotifier>().cameraAspectRatio;
            } else {
              notifier.aspectRation = context.read<CameraNotifier>().cameraAspectRatio;
            }
            notifier.featureType = featureType;
            notifier.showNext = false;
            await _routing.move(Routes.previewContent);
          } else {
            setLoading(false);
            if (value.keys.single.isNotEmpty) ShowGeneralDialog.pickFileErrorAlert(context, value.keys.single);
          }
        });
      });
    } catch (e) {
      setLoading(false);
      // ShowGeneralDialog.pickFileErrorAlert(context, language.sorryUnexpectedErrorHasOccurred ?? '');
      ShowGeneralDialog.pickFileErrorAlert(context, e.toString());
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  //////////////////////////////////////////////////////////////// Camera function

  void cancelVideoRecordingWhenAppIsPausedOrInactive() {
    WakelockPlus.disable();
    "================ disable wakelock 7".logger();
    cancelTimer();
    _progressDev = 0.0;
    _progressHuman = 0;
    _elapsedProgress = 0;
  }

  @override
  void onStopRecordedVideo(BuildContext context) {
    try {
      final tempDuration = Duration(seconds: elapsedProgress);
      dynamic cameraNotifier;

      WakelockPlus.disable();
      "================ disable wakelock 6".logger();
      final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
      if (canDeppAr == 'true') {
        cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
      } else {
        cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
      }

      cancelTimer();
      _progressDev = 0.0;
      _progressHuman = 0;
      _elapsedProgress = 0;
      cameraNotifier.stopVideoRecording(context).then((file) async {
        final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
        if (file?.path != null) {
          notifier.fileContent = [file?.path ?? ''];
        } else {
          if (canDeppAr == 'true') {
            final newFile = await Provider.of<CameraDevicesNotifier>(context, listen: false).cameraController?.stopVideoRecording();
            notifier.fileContent = [newFile?.path ?? ''];
          } else {
            final newFile = await Provider.of<CameraNotifier>(context, listen: false).deepArController?.stopVideoRecording();
            notifier.fileContent = [newFile?.path ?? ''];
          }
        }
        notifier.featureType = featureType;
        notifier.aspectRation = cameraNotifier.cameraAspectRatio;

        notifyListeners();
        messageToast = notifier.featureType == FeatureType.story ? (notifier.language.recordAtLeast4Seconds ?? 'Error') : (notifier.language.recordAtLeast15Seconds ?? 'Error');
        if (featureType == FeatureType.story) {
          // if (tempDuration.inMilliseconds >= 4900) {
          //   await _routing.move(Routes.previewContent);
          // } else {
          //   showVideoToast(const Duration(seconds: 3));
          // }
          await _routing.move(Routes.previewContent);
        } else {
          // if (tempDuration.inMilliseconds >= 15900) {
          await _routing.move(Routes.previewContent);
          // } else {
          //   showVideoToast(const Duration(seconds: 3));
          // }
        }
      });
    } catch (e) {
      e.logger();
    }
  }

  @override
  void onRecordedVideo(BuildContext context) async {
    print('start recording');
    dynamic cameraNotifier;
    final fixContext = Routing.navigatorKey.currentContext ?? context;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);

    if (canDeppAr == 'true') {
      cameraNotifier = Provider.of<CameraDevicesNotifier>(fixContext, listen: false);
    } else {
      cameraNotifier = Provider.of<CameraNotifier>(fixContext, listen: false);
    }
    _startTimer(fixContext);
    cameraNotifier.startVideoRecording(context);
    if (!(await WakelockPlus.enabled)) {
      WakelockPlus.enable();
    }
  }

  @override
  void onPauseRecordedVideo(BuildContext context) {
    dynamic cameraNotifier;

    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    if (canDeppAr == 'true') {
      cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    } else {
      cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    }
    WakelockPlus.enable();
    print('pause execute');
    cameraNotifier.pauseVideoRecording();
  }

  @override
  void onResumeRecordedVideo(BuildContext context) async {
    dynamic cameraNotifier;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    if (canDeppAr == 'true') {
      cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    } else {
      cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    }
    cameraNotifier.resumeVideoRecording().then((_) {
      cancelTimer();
      _startTimer(context);
    });
    if (!(await WakelockPlus.enabled)) {
      WakelockPlus.enable();
    }
  }

  @override
  void onTakePicture(BuildContext context) {
    dynamic cameraNotifier;
    final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);
    if (canDeppAr == 'true') {
      cameraNotifier = Provider.of<CameraDevicesNotifier>(context, listen: false);
    } else {
      cameraNotifier = Provider.of<CameraNotifier>(context, listen: false);
    }
    cameraNotifier.takePicture(context).then((filePath) async {
      if (filePath != null) {
        final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
        notifier.fileContent = [filePath.path];
        notifier.aspectRation = cameraNotifier.cameraAspectRatio;
        notifier.featureType = featureType;
        await _routing.move(Routes.previewContent);
      }
    });
  }

  final canDeppAr = SharedPreference().readStorage(SpKeys.canDeppAr);

  @override
  bool get hasError => canDeppAr == 'true' ? cameraDevicesNotifier.hasError : cameraNotifier.hasError;

  @override
  bool get isInitialized => canDeppAr == 'true' ? cameraDevicesNotifier.isInitialized : cameraNotifier.isInitialized;

  @override
  bool get isRecordingPaused => canDeppAr == 'true' ? cameraDevicesNotifier.isRecordingPaused : cameraNotifier.isRecordingPaused;

  @override
  bool get isRecordingVideo => canDeppAr == 'true' ? cameraDevicesNotifier.isRecordingVideo : cameraNotifier.isRecordingVideo;

  @override
  bool get isTakingPicture => canDeppAr == 'true' ? cameraDevicesNotifier.isTakingPicture : cameraNotifier.isTakingPicture;
}
