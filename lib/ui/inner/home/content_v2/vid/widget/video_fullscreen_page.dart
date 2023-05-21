import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';

import '../../../../../../core/config/ali_config.dart';
import '../../../../../../core/models/collection/posts/content_v2/content_data.dart';

class VideoFullscreenPage extends StatefulWidget {
  final AliPlayerView aliPlayerView;
  final ContentData data;
  final Function onClose;
  final FlutterAliplayer? fAliplayer;
  final Widget? slider;
  final VideoIndicator videoIndicator;
  const VideoFullscreenPage({
    Key? key,
    required this.aliPlayerView,
    required this.data,
    required this.onClose,
    this.fAliplayer,
    this.slider,
    required this.videoIndicator,
  }) : super(key: key);

  @override
  State<VideoFullscreenPage> createState() => _VideoFullscreenPageState();
}

class _VideoFullscreenPageState extends State<VideoFullscreenPage> with AfterFirstLayoutMixin {
  int seekValue = 0;
  bool isMute = false;
  bool _inSeek = false;
  int _currentPosition = 0;
  int _currentPositionText = 0;
  int _bufferPosition = 0;
  int _videoDuration = 1;
  bool isPause = false;
  bool onTapCtrl = false;
  bool _showTipsWidget = false;
  int _currentPlayerState = 0;

  @override
  void afterFirstLayout(BuildContext context) {
    landscape();
  }

  void landscape() async{
    widget.fAliplayer?.pause();
    if ((widget.data.metadata?.height ?? 0) < (widget.data.metadata?.width ?? 0)) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    widget.fAliplayer?.play();
  }

  @override
  void initState() {
    _currentPositionText = widget.videoIndicator.positionText;
    _currentPosition = widget.videoIndicator.seekValue;
    widget.fAliplayer?.play();
    _videoDuration = widget.videoIndicator.videoDuration;
    isMute = widget.videoIndicator.isMute;
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);



    widget.fAliplayer?.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == FlutterAvpdef.CURRENTPOSITION) {
        if (_videoDuration != 0 && (extraValue ?? 0) <= _videoDuration) {
          _currentPosition = extraValue ?? 0;
        }
        if (!_inSeek) {
          // setState(() {
          _currentPositionText = extraValue ?? 0;
          // });
        }
      } else if (infoCode == FlutterAvpdef.BUFFEREDPOSITION) {
        _bufferPosition = extraValue ?? 0;
        if (mounted) {
          setState(() {});
        }
      } else if (infoCode == FlutterAvpdef.AUTOPLAYSTART) {
        // Fluttertoast.showToast(msg: "AutoPlay");
      } else if (infoCode == FlutterAvpdef.CACHESUCCESS) {
        // Fluttertoast.showToast(msg: "Cache Success");
      } else if (infoCode == FlutterAvpdef.CACHEERROR) {
        // Fluttertoast.showToast(msg: "Cache Error $extraMsg");
      } else if (infoCode == FlutterAvpdef.LOOPINGSTART) {
        // Fluttertoast.showToast(msg: "Looping Start");
      } else if (infoCode == FlutterAvpdef.SWITCHTOSOFTWAREVIDEODECODER) {
        // Fluttertoast.showToast(msg: "change to soft ware decoder");
        // mOptionsFragment.switchHardwareDecoder();
      }
    });

    widget.fAliplayer?.setOnCompletion((playerId) {
      _showTipsWidget = true;
      isPause = true;
      setState(() {
        _currentPosition = _videoDuration;
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    var map = {
      DataSourceRelated.vidKey: widget.data.apsaraId,
      DataSourceRelated.regionKey: DataSourceRelated.defaultRegion,
    };
    return WillPopScope(
      onWillPop: () async {
        widget.data.isLoading = true;
        // widget.fAliplayer?.pause();
        setState(() {});
        return true;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            onTapCtrl = true;
            setState(() {});
          },
          child: Stack(
            children: [
              Container(width: context.getWidth(), height: SizeConfig.screenHeight, decoration: const BoxDecoration(color: Colors.black), child: widget.aliPlayerView),
              if(!_showTipsWidget)
              SizedBox(
                width: context.getWidth(),
                height: SizeConfig.screenHeight,
                // padding: EdgeInsets.only(bottom: 25.0),
                child: Offstage(offstage: false, child: _buildContentWidget(context, Orientation.portrait)),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: _buildController(
                  Colors.transparent,
                  Colors.white,
                  100,
                  context.getWidth(),
                  SizeConfig.screenHeight ?? 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return WillPopScope(
    //   onWillPop: () async {
    //     widget.fAliplayer?.pause();
    //     return true;
    //   },
    //   child: Material(
    //     child: Container(
    //       width: context.getWidth(),
    //       height: context.getHeight(),
    //       decoration: const BoxDecoration(color: Colors.black),
    //       child: VidPlayerPage(
    //         playMode: (widget.data.isApsara ?? false) ? ModeTypeAliPLayer.auth : ModeTypeAliPLayer.url,
    //         dataSourceMap: map,
    //         data: widget.data,
    //         functionFullTriger: widget.onClose,
    //         inLanding: true,
    //         orientation: Orientation.landscape,
    //         seekValue: widget.seekValue,
    //       ),
    //     ),
    //   ),
    // );
  }

  _buildContentWidget(BuildContext context, Orientation orientation) {
    // print('ORIENTATION: CHANGING ORIENTATION');
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                sixPx,
                Text(
                  System.getTimeformatByMs(_currentPositionText),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                sixPx,
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      overlayShape: SliderComponentShape.noThumb,
                      activeTrackColor: const Color(0xAA7d7d7d),
                      inactiveTrackColor: const Color.fromARGB(170, 156, 155, 155),
                      // trackShape: RectangularSliderTrackShape(),
                      trackHeight: 3.0,
                      thumbColor: Colors.purple,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    ),
                    child: Slider(
                        min: 0,
                        max: _videoDuration == 0 ? 1 : _videoDuration.toDouble(),
                        value: _currentPosition.toDouble(),
                        activeColor: Colors.purple,
                        // trackColor: Color(0xAA7d7d7d),
                        thumbColor: Colors.purple,
                        onChangeStart: (value) {
                          _inSeek = true;
                          // _showLoading = false;
                          setState(() {});
                        },
                        onChangeEnd: (value) {
                          _inSeek = false;
                          setState(() {
                            if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
                              setState(() {
                                _showTipsWidget = false;
                              });
                            }
                          });
                          // isActiveAds
                          //     ? fAliplayerAds?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE)
                          //     : fAliplayer?.seekTo(value.ceil(), GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
                          widget.fAliplayer?.seekTo(value.ceil(), FlutterAvpdef.ACCURATE);
                        },
                        onChanged: (value) {
                          print('on change');

                          widget.fAliplayer?.requestBitmapAtPosition(value.ceil());

                          setState(() {
                            _currentPosition = value.ceil();
                          });
                        }),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isMute = !isMute;
                    });
                    widget.fAliplayer?.setMuted(isMute);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: CustomIconWidget(
                      iconData: isMute ? '${AssetPath.vectorPath}sound-off.svg' : '${AssetPath.vectorPath}sound-on.svg',
                      defaultColor: false,
                      height: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    int changevalue;
                    changevalue = _currentPosition + 1000;
                    if (changevalue > _videoDuration) {
                      changevalue = _videoDuration;
                    }
                    widget.data.isLoading = true;
                    setState(() {});
                    Navigator.pop(
                        context,
                        VideoIndicator(
                            videoDuration: _videoDuration,
                            seekValue: changevalue,
                            positionText: _currentPositionText,
                            showTipsWidget: _showTipsWidget, isMute: isMute));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPlayerHide() {
    Future.delayed(const Duration(seconds: 4), () {
      onTapCtrl = false;
      // setState(() {});
    });
  }

  Widget _buildController(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
    double width,
    double height,
  ) {
    return AnimatedOpacity(
      opacity: onTapCtrl || isPause ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      onEnd: _onPlayerHide,
      child: Container(
        height: height * 0.8,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: _showTipsWidget ? Center(
          child: GestureDetector(
            onTap: (){
              widget.fAliplayer?.prepare();
              widget.fAliplayer?.play();
              setState(() {
                isPause = false;
                _showTipsWidget = false;
              });
            },
            child: const CustomIconWidget(
          iconData: "${AssetPath.vectorPath}pause.svg",
            defaultColor: false,
          ),
          ),
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSkipBack(iconColor, barHeight),
            _buildPlayPause(iconColor, barHeight),
            _buildSkipForward(iconColor, barHeight),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: () {
        if (isPause) {
          // if (_showTipsWidget) fAliplayer?.prepare();
          widget.fAliplayer?.play();
          isPause = false;
          setState(() {});
        } else {
          widget.fAliplayer?.pause();
          isPause = true;
          setState(() {});
        }
        if (_showTipsWidget) {
          widget.fAliplayer?.prepare();
          widget.fAliplayer?.play();
        }
      },
      child: CustomIconWidget(
        iconData: isPause ? "${AssetPath.vectorPath}pause.svg" : "${AssetPath.vectorPath}play.svg",
        defaultColor: false,
      ),
      // Icon(
      //   isPause ? Icons.pause : Icons.play_arrow_rounded,
      //   color: iconColor,
      //   size: 200,
      // ),
    );
  }

  GestureDetector _buildSkipBack(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }

        changevalue = _currentPosition - value;
        if (changevalue < 0) {
          changevalue = 0;
        }
        widget.fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        widget.fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}replay10.svg",
        defaultColor: false,
      ),
    );
  }

  GestureDetector _buildSkipForward(Color iconColor, double barHeight) {
    return GestureDetector(
      onTap: () {
        if (!onTapCtrl) return;
        int value;
        int changevalue;
        if (_videoDuration > 60000) {
          value = 10000;
        } else {
          value = 5000;
        }
        changevalue = _currentPosition + value;
        if (changevalue > _videoDuration) {
          changevalue = _videoDuration;
        }
        widget.fAliplayer?.requestBitmapAtPosition(changevalue);
        setState(() {
          _currentPosition = changevalue;
        });
        _inSeek = false;
        setState(() {
          if (_currentPlayerState == FlutterAvpdef.completion && _showTipsWidget) {
            setState(() {
              _showTipsWidget = false;
            });
          }
        });
        // fAliplayer?.seekTo(changevalue, GlobalSettings.mEnableAccurateSeek ? FlutterAvpdef.ACCURATE : FlutterAvpdef.INACCURATE);
        widget.fAliplayer?.seekTo(changevalue, FlutterAvpdef.ACCURATE);
      },
      child: const CustomIconWidget(
        iconData: "${AssetPath.vectorPath}forward10.svg",
        defaultColor: false,
      ),
    );
  }


}

class VideoIndicator{
  final int videoDuration;
  final int seekValue;
  final int positionText;
  final bool showTipsWidget;
  final bool isMute;
  VideoIndicator({required this.videoDuration, required this.seekValue, required this.positionText, this.showTipsWidget = false, required this.isMute});
}
