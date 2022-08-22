import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';

// class CameraView extends StatelessWidget {
//   DeepArController? controller;
//   CameraView({Key? key, this.controller}) : super(key: key);

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
//               // child: CameraPreview(notifier.cameraController!), //for camera
//               child: DeepArPreview(controller!),
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
import 'dart:convert';

class CameraView extends StatefulWidget {
  DeepArController controller;
  CameraView({Key? key, required this.controller}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  String version = '';
  bool _isFaceMask = false;
  bool _isFilter = false;

  final List<String> _effectsList = [];
  final List<String> _maskList = [];
  final List<String> _filterList = [];
  int _effectIndex = 0;
  int _maskIndex = 0;
  int _filterIndex = 0;

  final String _assetEffectsPath = 'assets/effects/';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _initEffects();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        widget.controller.isInitialized
            ? DeepArPreview(widget.controller)
            : const Center(
                child: Text("Loading..."),
              ),
        _topMediaOptions(),
        _bottomMediaOptions(),
      ],
    ));
  }

  // flip, face mask, filter, flash
  Positioned _topMediaOptions() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              await widget.controller.toggleFlash();
              setState(() {});
            },
            color: Colors.white70,
            iconSize: 40,
            icon: Icon(widget.controller.flashState ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: () async {
              _isFaceMask = !_isFaceMask;
              if (_isFaceMask) {
                widget.controller.switchFaceMask(_maskList[_maskIndex]);
              } else {
                widget.controller.switchFaceMask("null");
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
                widget.controller.switchFilter(_filterList[_filterIndex]);
              } else {
                widget.controller.switchFilter("null");
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
                widget.controller.flipCamera();
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
  Positioned _bottomMediaOptions() {
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
                    widget.controller.switchFaceMask(prevMask);
                  } else if (_isFilter) {
                    String prevFilter = _getPrevFilter();
                    widget.controller.switchFilter(prevFilter);
                  } else {
                    String prevEffect = _getPrevEffect();
                    widget.controller.switchEffect(prevEffect);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white70,
                )),
            IconButton(
                onPressed: () async {
                  if (widget.controller.isRecording) {
                    File? file = await widget.controller.stopVideoRecording();
                    // OpenFile.open(file.path);
                  } else {
                    await widget.controller.startVideoRecording();
                  }

                  setState(() {});
                },
                iconSize: 50,
                color: Colors.white70,
                icon: Icon(widget.controller.isRecording ? Icons.videocam_sharp : Icons.videocam_outlined)),
            const SizedBox(width: 20),
            IconButton(
                onPressed: () {
                  widget.controller.takeScreenshot().then((file) {
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
                    widget.controller.switchFaceMask(nextMask);
                  } else if (_isFilter) {
                    String nextFilter = _getNextFilter();
                    widget.controller.switchFilter(nextFilter);
                  } else {
                    String nextEffect = _getNextEffect();
                    widget.controller.switchEffect(nextEffect);
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
    // Either get all effects
    _getEffectsFromAssets(context).then((values) {
      _effectsList.clear();
      _effectsList.addAll(values);

      _maskList.clear();
      _maskList.add(_assetEffectsPath + 'Emotions_Exaggerator.deepar');
      _maskList.add(_assetEffectsPath + 'flower_face.deepar');

      _filterList.clear();
      _filterList.add(_assetEffectsPath + 'Emotions_Exaggerator.deepar');
      _filterList.add(_assetEffectsPath + 'flower_face.deepar');

      _effectsList.removeWhere((element) => _maskList.contains(element));

      _effectsList.removeWhere((element) => _filterList.contains(element));
    });

    // OR

    // Only add specific effects
    // _effectsList.add(_assetEffectsPath+'burning_effect.deepar');
    // _effectsList.add(_assetEffectsPath+'flower_face.deepar');
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
