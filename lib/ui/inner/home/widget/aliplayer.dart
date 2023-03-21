import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';

class AliPlayer extends StatefulWidget {
  const AliPlayer({Key? key}) : super(key: key);

  @override
  State<AliPlayer> createState() => _AliPlayerState();
}

class _AliPlayerState extends State<AliPlayer> {
  FlutterAliplayer fAliplayer = FlutterAliPlayerFactory.createAliPlayer();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'AliPlayer');
    // Listens to successful preparation.
    fAliplayer.setOnPrepared((playerId) {});
// Listens to the display of the first frame.
    fAliplayer.setOnRenderingStart((playerId) {});
// Listens to changes in the width or height of a video.
    // fAliplayer.setOnVideoSizeChanged((width, height, playerId) {});
// Listens to changes of the player status.
    fAliplayer.setOnStateChanged((newState, playerId) {});
// Listens to the loading status.
    fAliplayer.setOnLoadingStatusListener(loadingBegin: (playerId) {}, loadingProgress: (percent, netSpeed, playerId) {}, loadingEnd: (playerId) {});
// Listens to the completion of seeking.
    fAliplayer.setOnSeekComplete((playerId) {});
// Listens to event callbacks, such as the buffer and playback progress. You can obtain event information based on the value of the FlutterAvpdef.infoCode parameter.
    fAliplayer.setOnInfo((infoCode, extraValue, extraMsg, playerId) {});
// Listens to the completion of playback.
    fAliplayer.setOnCompletion((playerId) {});
// Listens to a stream that is ready.
    fAliplayer.setOnTrackReady((playerId) {});
// Listens to a snapshot that is captured.
    fAliplayer.setOnSnapShot((path, playerId) {});
// Listens to an error.
    fAliplayer.setOnError((errorCode, errorExtra, errorMsg, playerId) {});
// Listens to stream switching.
    fAliplayer.setOnTrackChanged((value, playerId) {});
    super.initState();
  }

  Map _dataSourceMap = {};
  ModeTypeAliPLayer _playMode = ModeTypeAliPLayer.url;

  // void onViewPlayerCreated(viewId) async {
  //   ///将 渲染 View 设置给播放器
  //   fAliplayer.setPlayerView(1);
  //   //设置播放源
  //   switch (_playMode) {
  //     //URL 播放方式
  //     case ModeType.URL:
  //       fAliplayer.setUrl("https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4");
  //       break;
  //     //STS 播放方式
  //     case ModeType.STS:
  //       fAliplayer.setVidSts(
  //         vid: _dataSourceMap[DataSourceRelated.VID_KEY],
  //         region: _dataSourceMap[DataSourceRelated.REGION_KEY],
  //         accessKeyId: _dataSourceMap[DataSourceRelated.ACCESSKEYID_KEY],
  //         accessKeySecret: _dataSourceMap[DataSourceRelated.ACCESSKEYSECRET_KEY],
  //         securityToken: _dataSourceMap[DataSourceRelated.SECURITYTOKEN_KEY],
  //       );
  //       break;
  //     //AUTH 播放方式
  //     case ModeType.AUTH:
  //       fAliplayer.setVidAuth(
  //           vid: _dataSourceMap[DataSourceRelated.VID_KEY],
  //           region: _dataSourceMap[DataSourceRelated.REGION_KEY],
  //           playAuth: _dataSourceMap[DataSourceRelated.PLAYAUTH_KEY],
  //           definitionList: _dataSourceMap[DataSourceRelated.DEFINITION_LIST],
  //           previewTime: _dataSourceMap[DataSourceRelated.PREVIEWTIME_KEY]);
  //       break;
  //     default:
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    Orientation orientation = MediaQuery.of(context).orientation;
    var width = MediaQuery.of(context).size.width;

    double height;
    if (orientation == Orientation.portrait) {
      height = width * 9.0 / 16.0;
    } else {
      height = MediaQuery.of(context).size.height;
    }
    // AliPlayerView aliPlayerView = AliPlayerView(onCreated: onViewPlayerCreated, x: x, y: y, width: width, height: height);
    return SizedBox(
      height: 300,
      width: 200,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Scaffold(
            body: Column(
              children: [
                Container(
                  color: Colors.black, width: width, height: height, //child: aliPlayerView
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
