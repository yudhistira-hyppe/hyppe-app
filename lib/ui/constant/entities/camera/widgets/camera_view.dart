import 'dart:io';

import 'package:flutter/material.dart';
import 'package:deepar_flutter/deepar_flutter.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/entities/camera/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

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
  final List<String> _maskList = [];
  final List<String> _filterList = [];
  int _effectIndex = 0;
  int _maskIndex = 0;
  int _filterIndex = 0;
  int effected = -1;

  // final String _assetEffectsPath = 'assets/effect/';

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
    final notifier = context.read<CameraNotifier>();
    notifier.deepArController ??= DeepArController();
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
    // if (_notifier.deepArController.isInitialized) {
    //   _notifier.deepArController.destroy();
    // }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceRatio = context.getWidth() / context.getHeight();
    return Consumer<CameraNotifier>(
      builder: (_, notifier, __) => Scaffold(
          body: !notifier.isRestart ? Stack(
        children: [
          notifier.deepArController == null
              ? const CustomLoading()
              : notifier.isInitialized
                  ? Transform.scale(
                      scale: (1 / notifier.deepArController!.aspectRatio) / deviceRatio,
                      child: DeepArPreview(
                        notifier.deepArController!,
                        onViewCreated: () {
                          // set any initial effect, filter etc
                          // _controller.switchEffect(
                          //     _assetEffectsPath + 'viking_helmet.deepar');
                        },
                      ),
                    )
                  : const Center(
                      child: Text("Loading..."),
                    ),
          notifier.showEffected ? listEfect(notifier.deepArController!) : const SizedBox(),
          // _topMediaOptions(notifier.deepArController),
          // _bottomMediaOptions(notifier.deepArController),
        ],
      ): const Center(child: CustomLoading(),)),
    );
  }

  Positioned listEfect(DeepArController _controller) {
    final notifier = context.watch<CameraNotifier>();
    var token = SharedPreference().readStorage(SpKeys.userToken);
    var email = SharedPreference().readStorage(SpKeys.email);

    return Positioned(
        top: Platform.isIOS ? 80 : 40,
        left: 0,
        right: 0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 80,
          // width: 300,
          child: ListView.builder(
              shrinkWrap: true,
              // physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifier.effects.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                var _effect = notifier.effects[index];
                return Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      if (!notifier.isDownloadingEffect) {
                        setState(() => effected = index);
                        notifier.setDeepAREffect(context, _effect);
                      }
                    },
                    child: Container(
                        width: effected == index ? 60 : 40,
                        height: effected == index ? 60 : 40,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red,
                            image: DecorationImage(
                              alignment: Alignment.center,
                              matchTextDirection: true,
                              fit: BoxFit.cover,
                              image: NetworkImage('${Env.data.baseUrl}/api/assets/filter/image/thumb/${_effect.postID}?x-auth-user=$email&x-auth-token=$token'),
                          ),
                        ),
                        child: (effected == index && notifier.isDownloadingEffect) ? const CustomLoading() : Container(),
                      ),
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
                    // File? file = await _controller.stopVideoRecording();
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
