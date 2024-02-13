import 'dart:io';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/effect/bloc.dart';
import 'package:hyppe/core/bloc/effect/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/models/collection/effect/effect_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:camera/camera.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path;

class CameraNotifier extends LoadingNotifier with ChangeNotifier {
  static final _system = System();
  Dio dio = Dio();
  DeepArController? deepArController = DeepArController();
  String? _iOSVersion;
  CameraController? cameraController;
  List<CameraDescription> camera = [];
  FlashMode flashMode = FlashMode.off;
  NativeDeviceOrientation? orientation;

  bool isInitializedIos = false;
  bool get isInitialized => (Platform.isIOS ? isInitializedIos : (deepArController?.isInitialized ?? false));
  bool get isRecordingVideo => deepArController?.isRecording ?? false;
  bool get isRecordingPaused => deepArController?.isRecording ?? false;
  bool get isTakingPicture => cameraController?.value.isTakingPicture ?? false;
  bool get hasError => cameraController?.value.hasError ?? false;
  double get cameraAspectRatio => (deepArController?.imageDimensions.height ?? 0.0) / (deepArController?.imageDimensions.width ?? 0.0);
  double get yScale => 1;

  bool _isRestart = false;
  bool get isRestart => _isRestart;
  set isRestart(bool state){
    _isRestart = state;
    notifyListeners();
  }

  bool _showEffected = false;
  bool get showEffected => _showEffected;

  bool _isFlash = false;
  bool get isFlash => _isFlash;
  set isFlash(bool state) {
    _isFlash = state;
    notifyListeners();
  }

  set showEffected(bool val) {
    _showEffected = val;
    notifyListeners();
  }

  List<EffectModel> _effects = [];
  List<EffectModel> get effects => _effects;
  set effects(val) {
    _effects = val;
    notifyListeners();
  }

  EffectModel? _selectedEffect;
  EffectModel? get selectedEffect => _selectedEffect;
  set selectedEffect(val) {
    _selectedEffect = val;
    notifyListeners();
  }

  String _effectPath = '';
  String get effectPath => _effectPath;
  set effectPath(val) {
    _effectPath = val;
    notifyListeners();
  }

  bool _isDownloadingEffect = false;
  bool get isDownloadingEffect => _isDownloadingEffect;
  set isDownloadingEffect(bool state) {
    _isDownloadingEffect = state;
    notifyListeners();
  }

  // Object Key
  static const String loadingForSwitching = 'loadingForSwitching';

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  Future<void> initCamera(BuildContext context, bool mounted, {bool backCamera = false}) async {
    // print('DeepAR: initCamera, mounted: ');print(mounted);
    try {
      final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
      flashMode = FlashMode.torch;
      isFlash = false;
      deepArController ??= DeepArController();

      print('Initializing DeepAR');
      await deepArController!
          .initialize(
        androidLicenseKey: "2a5a8cfda693ae38f2e20925295b950b13f0a7c186dcd167b5997655932d82ceb0cbc27be4c0b513",
        iosLicenseKey: "6389e21310378b39591d7a24897a1f59456ce3c5cf0fbf89033d535438d2f1cf10ea4829b25cf117",
        resolution: _configureResolutionDeepArPreset(onStoryIsPhoto: notifier.featureType == FeatureType.story ? !notifier.isVideo : null),
      )
          .then((value) {
        print('DeepAR: DeepAR done initialized $value');
        isInitializedIos = true;
        print(deepArController!.isInitialized);
        print(isInitialized);
        initEffect(context);
      });
      if (backCamera) {
        deepArController?.flipCamera();
      }

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
      'CameraException : ${e.description}'.logger();
    } catch (e) {
      'Error DeepAr : $e'.logger();
    }
    if (!mounted) {
      return;
    }
    print('notifyListeners()');
    notifyListeners();
  }

  Future<void> initEffect(BuildContext context) async {
    Directory directory = await path.getApplicationSupportDirectory();
    effectPath = directory.path;
    notifyListeners();
    try {
      final notifier = EffectBloc();
      await notifier.getEffects(context);
      final fetch = notifier.effectFetch;
      if (fetch.state == EffectState.getEffectSuccess) {
        List<EffectModel>? res = (fetch.data as List<dynamic>?)?.map((e) => EffectModel.fromJson(e as Map<String, dynamic>)).toList();
        effects = res;
      }
      notifyListeners();
    } catch (e) {
      'get effect: ERROR: $e'.logger();
    }
  }

  Future notUseEffect(BuildContext context) async{
    isRestart = true;
    await deepArController?.destroy();
    deepArController = DeepArController();
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    await deepArController!
        .initialize(
    androidLicenseKey: "2a5a8cfda693ae38f2e20925295b950b13f0a7c186dcd167b5997655932d82ceb0cbc27be4c0b513",
    iosLicenseKey: "6389e21310378b39591d7a24897a1f59456ce3c5cf0fbf89033d535438d2f1cf10ea4829b25cf117",
    resolution: _configureResolutionDeepArPreset(onStoryIsPhoto: notifier.featureType == FeatureType.story ? !notifier.isVideo : null),
    )
        .then((value) {
    print('DeepAR: DeepAR done initialized $value');
    Future.delayed(const Duration(milliseconds: 1000), (){
      isRestart = false;
    });
    isInitializedIos = true;
    print(deepArController!.isInitialized);
    print(isInitialized);
    initEffect(context);
    });
  }

  Future<void> setDeepAREffect(BuildContext context, EffectModel effectModel) async {
    Directory directory = await path.getApplicationSupportDirectory();
    var filePath = '${directory.path}${Platform.pathSeparator}${effectModel.fileAssetName}';

    if (await File(filePath).exists()) {
      deepArController?.switchEffect(filePath);
    } else {
      try {
        if (context.mounted) {
          final notifier = EffectBloc();
          isDownloadingEffect = true;
          notifyListeners();
          File saveFile = File(filePath);
          await notifier.downloadEffect(
            context: context,
            effectID: effectModel.postID,
            savePath: saveFile.path,
            whenComplete: () {
              deepArController?.switchEffect(filePath);
              isDownloadingEffect = false;
              notifyListeners();
            },
          );
        }
      } catch (err) {
        err.logger();
        isDownloadingEffect = false;
        notifyListeners();
      }
    }

    // final email = SharedPreference().readStorage(SpKeys.email);
    // final token = SharedPreference().readStorage(SpKeys.userToken);
    // if (await File(filePath).exists()) {
    //   deepArController?.switchEffect(filePath);
    // } else {
    //   isDownloadingEffect = true;
    //   notifyListeners();
    //   File saveFile = File(filePath);
    //   try {
    //       var url = '${Env.data.baseUrl}/api/assets/filter/file/${effectModel.postID}?x-auth-user=$email&x-auth-token=$token';
    //       await dio.download(url, saveFile.path, onReceiveProgress: (received, total) {
    //       int progress = (((received / total) * 100).toInt());
    //         progress.logger();
    //       }).whenComplete(() {
    //         deepArController?.switchEffect(filePath);
    //         isDownloadingEffect = false;
    //         notifyListeners();
    //       });
    //   } catch (err) {
    //     err.logger();
    //     isDownloadingEffect = false;
    //     notifyListeners();
    //   }
    // }
  }

  Future<void> onStoryPhotoVideo(bool isPhoto) async {
    if (loadingForObject(loadingForSwitching)) {
      setLoading(false, loadingObject: loadingForSwitching);
    } else {
      notifyListeners();
    }
  }

  Future<void> onNewCameraSelected(BuildContext context) async {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    print('DeepAR: balik kamera');
    // isFlash = false;
    deepArController!.flipCamera();
    print('myFlash: $isFlash');
    if(notifier.featureType == FeatureType.pic || (notifier.featureType == FeatureType.story && !notifier.isVideo)){

    }else{
      if (isFlash) {
        Future.delayed(const Duration(seconds: 1), () async {
          await deepArController!.toggleFlash();
        });
      }
    }

  }

  disposeCamera(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        deepArController ??= DeepArController();
        if (deepArController != null) {
          final isGranted = await System().requestPermission(context, permissions: [Permission.camera]);
          if (isGranted) {
            print('destroy deepArController 1 ');
            deepArController!.destroy();
          }
        }
        deepArController = null;
      }
      if (deepArController != null) {
        final isGranted = await System().requestPermission(context, permissions: [Permission.camera]);
        if (isGranted) {
          print('destroy deepArController 2');
          deepArController!.destroy();
        }
      }
      deepArController = null;
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

  Resolution _configureResolutionDeepArPreset({bool? onStoryIsPhoto}) {
    print('DeepAR: onStoryIsPhoto: ${onStoryIsPhoto}');
    print('DeepAR: Platform.isIOS: ${Platform.isIOS}, _iOSVersion: ${_iOSVersion}, minIphoneVersionForResolutionCamera: ${minIphoneVersionForResolutionCamera}');

    return Resolution.veryHigh;
  }

  Future<void> onFlashButtonPressed(BuildContext context) async {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    if(notifier.featureType == FeatureType.pic){
      isFlash = !isFlash;
    }else if(notifier.featureType == FeatureType.story){
      // if(notifier.isVideo){
      //   isFlash = await deepArController!.toggleFlash();
      // }else{
      //   isFlash = !isFlash;
      // }
      isFlash = !isFlash;
    }else{
      isFlash = await deepArController!.toggleFlash();
    }

  }

  void flashOff(BuildContext context) async {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    if(notifier.featureType == FeatureType.pic){
      if(isFlash){
        isFlash = !isFlash;
      }
    }else if(notifier.featureType == FeatureType.story){
      if(notifier.isVideo){
        if (deepArController!.flashState) {
          isFlash = await deepArController!.toggleFlash();
        }
      }else{
        if(isFlash){
          isFlash = !isFlash;
        }
      }
    }else{
      if (deepArController!.flashState) {
        isFlash = await deepArController!.toggleFlash();
      }
    }

  }

  String flashIcon() {
    print('flashMode $flashMode : ${deepArController!.flashState}');
    return isFlash ? "${AssetPath.vectorPath}ic_flash.svg" : "${AssetPath.vectorPath}ic_unflash.svg";
    // if(isFlash){
    //   return "${AssetPath.vectorPath}flash-off.svg";
    // }else{
    //   return "${AssetPath.vectorPath}flash.svg";
    // }
    // if (deepArController != null && deepArController!.flashState) {
    //   return "${AssetPath.vectorPath}flash-off.svg";
    // } else if (flashMode == FlashMode.auto) {
    //   return "${AssetPath.vectorPath}flash-auto.svg";
    // } else {
    //   return "${AssetPath.vectorPath}flash.svg";
    // }
  }

  Future<File?> takePicture(BuildContext context) async {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    if(notifier.featureType == FeatureType.pic || (notifier.featureType == FeatureType.story && !notifier.isVideo)){
      if (isFlash){
        await deepArController?.toggleFlash();
        await Future.delayed(const Duration(seconds: 1));
      }
    }else{
      if (isFlash) {
        isFlash = (await deepArController?.toggleFlash() ?? false);
      }
    }

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
        if(isFlash){
          deepArController?.toggleFlash();
        }
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

  Future<void> startVideoRecording(BuildContext context) async {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    print('play video');
    if (!isInitialized) {
      return;
    }
    if(notifier.featureType == FeatureType.story && isFlash){
      await deepArController?.toggleFlash();
    }

    if (isRecordingVideo) {
      return;
    }

    try {
      _showEffected = false;
      deepArController!.startVideoRecording();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return;
    }
  }

  Future<File?> stopVideoRecording(BuildContext context) async {
    final notifier = Provider.of<MakeContentNotifier>(context, listen: false);
    if (!isRecordingVideo) {
      return null;
    }

    if(notifier.featureType == FeatureType.story && isFlash){
      await deepArController?.toggleFlash();
    }else if (isFlash) {
      isFlash = (await deepArController?.toggleFlash() ?? false);
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
      await cameraController?.pauseVideoRecording();
      notifyListeners();
    } on CameraException catch (e) {
      e.logger();
      return;
    }
  }

  void showEffect({bool isClose = false}) {
    if (isClose) {
      _showEffected = false;
    } else {
      _showEffected = !_showEffected;
    }
    notifyListeners();
  }
}
