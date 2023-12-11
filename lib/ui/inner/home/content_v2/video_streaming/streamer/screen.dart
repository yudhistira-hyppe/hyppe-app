import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_livepush_plugin/live_pusher_preview.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class StreamerScreen extends StatefulWidget {
  const StreamerScreen({super.key});

  @override
  State<StreamerScreen> createState() => _StreamerScreenState();
}

class _StreamerScreenState extends State<StreamerScreen> {
  bool isloading = true;
  @override
  void initState() {
    bool theme = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   var streampro = Provider.of<StreamerNotifier>(context, listen: false);
    //   // streampro.init();
    //   Future.delayed(const Duration(milliseconds: 1000), () {
    //     setState(() {
    //       isloading = false;
    //     });
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            color: Colors.blue,
          ),
          beforeLive(),
        ],
      ),
    );
  }

  Widget beforeLive() {
    return SafeArea(
      child: Column(
        children: [
          Icon(Icons.close),
        ],
      ),
    );
  }

  Widget build2(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Scaffold(
        backgroundColor: Colors.white,
        body: WillPopScope(
          child: isloading
              ? Container(height: SizeConfig.screenHeight, child: Center(child: CustomLoading()))
              : Stack(
                  children: [
                    _buildPreviewWidget(context, notifier),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${SizeConfig.screenWidth}"),
                          Text("${SizeConfig.screenHeight}"),
                        ],
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.bottomLeft,
                    //   child: TextButton(
                    //     style: ButtonStyle(
                    //       backgroundColor: MaterialStateProperty.all(Colors.blue),
                    //       shape: MaterialStateProperty.all(
                    //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    //       ),
                    //       minimumSize: MaterialStateProperty.all(Size(100, 10)),
                    //     ),
                    //     onPressed: (() {
                    //       notifier.clickPushAction();
                    //     }),
                    //     child: Text(
                    //       "Stream",
                    //       style: TextStyle(
                    //         fontSize: 12.0,
                    //         color: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // _buildBottomWidget(state, viewService, dispatch),
                    // _buildRightWidget(state, viewService, dispatch),
                    // _buildTopViewWidget(state, viewService, dispatch),
                    // _buildQueenWidget(state, viewService, dispatch),
                  ],
                ),
          onWillPop: () async {
            notifier.destoryPusher();
            notifier.dispose();
            return true;
          },
        ),
        // bottomSheet: _buildBottomSheet(state, viewService, dispatch),
      ),
    );
  }

  Widget _buildPreviewWidget(BuildContext context, StreamerNotifier notifier) {
    var x = 0.0;
    var y = 0.0;
    var width = MediaQuery.of(context).size.width;
    var height = 1000.0;

    AlivcPusherPreviewType viewType;
    if (Platform.isAndroid) {
      if (notifier.livePushMode == 0) {
        viewType = AlivcPusherPreviewType.base;
      } else {
        viewType = AlivcPusherPreviewType.push;
      }
    } else {
      viewType = AlivcPusherPreviewType.push;
    }

    AlivcPusherPreview pusherPreviewView = AlivcPusherPreview(
      viewType: viewType,
      onCreated: (id) async {
        await Future.delayed(const Duration(milliseconds: 500));
        notifier.previewCreated();
      },
      x: x,
      y: y,
      width: width,
      height: height,
    );
    return Positioned(
      child: Container(color: Colors.black, width: width, height: height, child: pusherPreviewView),
    );
  }
}
