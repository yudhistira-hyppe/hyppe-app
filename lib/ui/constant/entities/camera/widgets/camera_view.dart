// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/extension/log_extension.dart';
// import 'package:hyppe/core/services/system.dart';
// import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:native_device_orientation/native_device_orientation.dart';
// import 'package:provider/provider.dart';

// class CameraView extends StatelessWidget {
//   // DeepArController? controller;
//   const CameraView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     final notifier = context.watch<CameraNotifier>();
//     final deviceRatio = SizeConfig.screenWidth! / SizeConfig.screenHeight!;

//     return NativeDeviceOrientationReader(
//       useSensor: true,
//       builder: (context) {
//         final orientation = NativeDeviceOrientationReader.orientation(context);
//         'Received new orientation: $orientation'.logger();
//         'Received new converted orientation: ${System().convertOrientation(orientation)}'.logger();

//         'Current device orientation: ${notifier.orientation}'.logger();

//         if (notifier.isRecordingVideo && notifier.orientation == null) {
//           notifier.orientation = orientation;
//           'Set orientation to $orientation'.logger();
//           'Set orientation to ${System().convertOrientation(orientation)}'.logger();
//         }

//         return Container(
//           child: AspectRatio(
//             aspectRatio: deviceRatio,
//             child: Transform(
//               alignment: Alignment.center,
//               child: CameraPreview(notifier.cameraController!), //for camera

//               transform: Matrix4.diagonal3Values(notifier.cameraAspectRatio / deviceRatio, notifier.yScale.toDouble(), 1),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // late final DeepArController _controller;
  String version = '';
  bool _isFaceMask = false;
  bool _isFilter = false;

  List _effectsList = [];
  List _effectsList2 = [];
  final List<String> _maskList = [];
  final List<String> _filterList = [];
  int _effectIndex = 0;
  int _maskIndex = 0;
  int _filterIndex = 0;
  int effected = -1;

  final String _assetEffectsPath = 'assets/effect/';

  @override
  void initState() {
    // final _notifier = context.read<CameraNotifier>();
    // final _notifier2 = context.read<MakeContentNotifier>();
    // _controller = DeepArController();
    // _controller
    //     .initialize(
    //         androidLicenseKey: "2a5a8cfda693ae38f2e20925295b950b13f0a7c186dcd167b5997655932d82ceb0cbc27be4c0b513",
    //         iosLicenseKey: "64896fe04955aa98c7c268edc133f80ccd63090ac80f327a5a5f72f5a60de30658a3af7c3a531bd8",
    //         resolution: Resolution.high
    //         // resolution: _notifier.configureResolutionDeepArPreset(onStoryIsPhoto: _notifier.featureType == FeatureType.story ? !notifier.isVideo : null),
    //         )
    //     .then((value) => setState(() {}));
    _effectsList2 = [
      {"path": "BurningEffect", "efect": "burning_effect.deepar", "preview": "preview.png"},
      {"path": "DevilNeonHorns", "efect": "Neon_Devil_Horns.deepar", "preview": "preview.png"},
      {"path": "ElephantTrunk", "efect": "Elephant_Trunk.deepar", "preview": "preview.png"},
      {"path": "EmotionMeter", "efect": "Emotion_Meter.deepar", "preview": "preview.png"},
      {"path": "EmotionsExaggerator", "efect": "Emotions_Exaggerator.deepar", "preview": "preview.png"},
      {"path": "FireEffect", "efect": "Fire_Effect.deepar", "preview": "preview.png"},
      {"path": "FlowerFace", "efect": "flower_face.deepar", "preview": "preview.png"},
      {"path": "Hope", "efect": "Hope.deepar", "preview": "preview.png"},
      {"path": "Humanoid", "efect": "Humanoid.deepar", "preview": "preview.png"},
      {"path": "MakeupLookw_Slipt", "efect": "Split_View_Look.deepar", "preview": "preview.jpg"},
      {"path": "PingPongMinigame", "efect": "Ping_Pong.deepar", "preview": "preview.png"},
      {"path": "Snail", "efect": "Snail.deepar", "preview": "preview.png"},
      {"path": "Stallone", "efect": "Stallone.deepar", "preview": "preview.png"},
      {"path": "VendettaMask", "efect": "Vendetta_Mask.deepar", "preview": "preview.png"},
      {"path": "VikingHelmetPBR", "efect": "viking_helmet.deepar", "preview": "preview.png"},
    ];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _initEffects();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // final _notifier = context.read<CameraNotifier>();
    // if (_notifier.deepArController!.isInitialized) {
    //   _notifier.deepArController!.destroy();
    // }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final notifier = context.watch<CameraNotifier>();
    final deviceRatio = SizeConfig.screenWidth! / SizeConfig.screenHeight!;

    return Consumer<CameraNotifier>(
      builder: (_, notifier, __) => Scaffold(
          body: Stack(
        children: [
          notifier.deepArController == null
              ? const CustomLoading()
              : notifier.deepArController!.isInitialized
                  ? Platform.isIOS
                      ? DeepArPreview(notifier.deepArController!)
                      : AspectRatio(
                          aspectRatio: deviceRatio,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.diagonal3Values(notifier.cameraAspectRatio / deviceRatio, notifier.yScale.toDouble(), 1),
                            child: DeepArPreview(notifier.deepArController!),
                          ),
                        )
                  : const Center(
                      child: Text("Loading..."),
                    ),
          notifier.showEffected ? listEfect(notifier.deepArController!) : const SizedBox(),
          // _topMediaOptions(notifier.deepArController!),
          // _bottomMediaOptions(notifier.deepArController!),
        ],
      )),
    );
  }

  Positioned listEfect(DeepArController _controller) {
    return Positioned(
        top: 40,
        left: 0,
        right: 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 80,
          // width: 300,
          child: ListView.builder(
              shrinkWrap: true,
              // physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _effectsList2.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      effected = index;
                      _controller.switchFaceMask(_assetEffectsPath + _effectsList2[index]['path'] + "/" + _effectsList2[index]['efect']);
                      setState(() {});
                    },
                    child: Container(
                        width: effected == index ? 60 : 40,
                        height: effected == index ? 60 : 40,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red,
                            image: DecorationImage(
                              alignment: Alignment.center,
                              matchTextDirection: true,
                              fit: BoxFit.cover,
                              // image: AssetImage("assets/effect/BurningEffect/preview.png"),
                              image: AssetImage("$_assetEffectsPath${_effectsList2[index]['path']}/${_effectsList2[index]['preview']}"),
                            ))),
                  ),
                );
              }),
        ));
  }

  // flip, face mask, filter, flash
  // not used
  Positioned _topMediaOptions(DeepArController _controller) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              await _controller.toggleFlash();
              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(_controller.flashState ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: () async {
              _isFaceMask = !_isFaceMask;
              if (_isFaceMask) {
                _controller.switchFaceMask(_maskList[_maskIndex]);
              } else {
                _controller.switchFaceMask("null");
              }

              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(
              _isFaceMask ? Icons.face_retouching_natural_rounded : Icons.face_retouching_off,
            ),
          ),
          IconButton(
            onPressed: () async {
              _isFilter = !_isFilter;
              if (_isFilter) {
                _controller.switchFilter(_filterList[_filterIndex]);
              } else {
                _controller.switchFilter("null");
              }
              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(
              _isFilter ? Icons.filter_hdr : Icons.filter_hdr_outlined,
            ),
          ),
          IconButton(
              onPressed: () {
                _controller.flipCamera();
              },
              iconSize: 50,
              color: Colors.white70,
              icon: const Icon(Icons.cameraswitch))
        ],
      ),
    );
  }

  // prev, record, screenshot, next
  /// Sample option which can be performed
  /// not used
  Positioned _bottomMediaOptions(DeepArController _controller) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                iconSize: 60,
                onPressed: () {
                  if (_isFaceMask) {
                    String prevMask = _getPrevMask();
                    _controller.switchFaceMask(prevMask);
                  } else if (_isFilter) {
                    String prevFilter = _getPrevFilter();
                    _controller.switchFilter(prevFilter);
                  } else {
                    String prevEffect = _getPrevEffect();
                    _controller.switchEffect(prevEffect);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white70,
                )),
            IconButton(
                onPressed: () async {
                  if (_controller.isRecording) {
                    File? file = await _controller.stopVideoRecording();
                    // OpenFile.open(file.path);
                  } else {
                    await _controller.startVideoRecording();
                  }

                  setState(() {});
                },
                iconSize: 50,
                color: Colors.white70,
                icon: Icon(_controller.isRecording ? Icons.videocam_sharp : Icons.videocam_outlined)),
            const SizedBox(width: 20),
            IconButton(
                onPressed: () {
                  _controller.takeScreenshot().then((file) {
                    // OpenFile.open(file.path);
                  });
                },
                color: Colors.white70,
                iconSize: 40,
                icon: const Icon(Icons.photo_camera)),
            IconButton(
                iconSize: 60,
                onPressed: () {
                  if (_isFaceMask) {
                    String nextMask = _getNextMask();
                    _controller.switchFaceMask(nextMask);
                  } else if (_isFilter) {
                    String nextFilter = _getNextFilter();
                    _controller.switchFilter(nextFilter);
                  } else {
                    String nextEffect = _getNextEffect();
                    _controller.switchEffect(nextEffect);
                  }
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                )),
          ],
        ),
      ),
    );
  }

  /// Add effects which are rendered via DeepAR sdk
  void _initEffects() {
    // print('initEffects()');
    // Either get all effects
    // _getEffectsFromAssets(context).then((values) {
    // _effectsList.clear();
    // _effectsList.addAll(values);

    // _maskList.clear();
    // _maskList.add(_assetEffectsPath + 'Emotions_Exaggerator.deepar');
    // _maskList.add(_assetEffectsPath + 'flower_face.deepar');

    // _filterList.clear();
    // _filterList.add(_assetEffectsPath + 'Emotions_Exaggerator.deepar');
    // _filterList.add(_assetEffectsPath + 'flower_face.deepar');

    // _effectsList.removeWhere((element) => _maskList.contains(element));

    // _effectsList.removeWhere((element) => _filterList.contains(element));
    // });
    // print(_effectsList2);

    // OR

    // Only add specific effects
    // _effectsList.add(_assetEffectsPath+'burning_effect.deepar');
    // _effectsList.add(_assetEffectsPath+'Emotions_Exaggerator.deepar');
    // _effectsList.add(_assetEffectsPath+'Hope.deepar');
    // _effectsList.add(_assetEffectsPath+'viking_helmet.deepar');
  }

  /// Get all deepar effects from assets
  ///
  Future<List<String>> _getEffectsFromAssets(BuildContext context) async {
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final filePaths = manifestMap.keys.where((path) => path.startsWith(_assetEffectsPath)).toList();
    return filePaths;
  }

  /// Get next effect
  String _getNextEffect() {
    _effectIndex < _effectsList.length ? _effectIndex++ : _effectIndex = 0;
    return _effectsList[_effectIndex];
  }

  /// Get previous effect
  String _getPrevEffect() {
    _effectIndex > 0 ? _effectIndex-- : _effectIndex = _effectsList.length;
    return _effectsList[_effectIndex];
  }

  /// Get next mask
  String _getNextMask() {
    _maskIndex < _maskList.length ? _maskIndex++ : _maskIndex = 0;
    return _maskList[_maskIndex];
  }

  /// Get previous mask
  String _getPrevMask() {
    _maskIndex > 0 ? _maskIndex-- : _maskIndex = _maskList.length;
    return _maskList[_maskIndex];
  }

  /// Get next filter
  String _getNextFilter() {
    _filterIndex < _filterList.length ? _filterIndex++ : _filterIndex = 0;
    return _filterList[_filterIndex];
  }

  /// Get previous filter
  String _getPrevFilter() {
    _filterIndex > 0 ? _filterIndex-- : _filterIndex = _filterList.length;
    return _filterList[_filterIndex];
  }
}
