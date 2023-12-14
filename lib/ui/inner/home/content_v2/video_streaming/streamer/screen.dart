import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_livepush_plugin/live_pusher_preview.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/beforelive.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/pauseLive.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/streamer.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class StreamerScreen extends StatefulWidget {
  const StreamerScreen({super.key});

  @override
  State<StreamerScreen> createState() => _StreamerScreenState();
}

class _StreamerScreenState extends State<StreamerScreen> with TickerProviderStateMixin {
  bool isloading = true;
  FocusNode commentFocusNode = FocusNode();
  AlivcPusherPreview? pusherPreviewView;

  bool isLiked = false;

  late AnimationController emojiController;

  @override
  void initState() {
    bool theme = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      emojiController = AnimationController(vsync: this, duration: const Duration(seconds: 7));
      var streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro.requestPermission(context);
      streampro.init(context);

      commentFocusNode.addListener(() {
        print("Has focus: ${commentFocusNode.hasFocus}");
      });

      AlivcPusherPreviewType viewType;
      // if (Platform.isAndroid) {
      //   if (notifier.livePushMode == 0) {
      //     viewType = AlivcPusherPreviewType.base;
      //   } else {
      //     viewType = AlivcPusherPreviewType.push;
      //   }
      // } else {
      //   viewType = AlivcPusherPreviewType.push;
      // }
      viewType = AlivcPusherPreviewType.base;

      pusherPreviewView = AlivcPusherPreview(
        viewType: viewType,
        onCreated: (id) async {
          // await Future.delayed(const Duration(milliseconds: 500));
          streampro.previewCreated();
        },
        x: 0,
        y: 0,
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
      );
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          isloading = false;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  // Widget build(BuildContext context) {
  //   SizeConfig().init(context);
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         Container(
  //           height: SizeConfig.screenHeight,
  //           width: SizeConfig.screenWidth,
  //           color: Colors.blue,
  //         ),
  //         // beforeLive(),
  //         // startCounting(),
  //         streamer(),
  //       ],
  //     ),
  //   );
  // }
  List<Offset> likeOffsets = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: WillPopScope(
          child: notifier.isloading
              ? Container(height: SizeConfig.screenHeight, child: Center(child: CustomLoading()))
              : Stack(
                  children: [
                    _buildPreviewWidget(context, notifier),

                    // notifier.statusLive == 'Offline'
                    //     ? const BeforeLive()
                    //     : notifier.statusLive == 'Prepare'
                    //         ? prepare()
                    //         : notifier.statusLive == 'StandBy'
                    //             ? startCounting(notifier.timeReady)
                    //             : notifier.statusLive == 'Ready'
                    //                 ? prepare(titile: "Siaran LIVE telah dimulai!")
                    //                 : Container(),
                    // if (notifier.statusLive == 'Ready' || notifier.statusLive == 'Online') StreamerWidget(),
                    PauseLive(),
                    StreamerWidget(commentFocusNode: commentFocusNode),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       a++;
                    //       _debouncer.run(() {
                    //         print(a);
                    //         a = 0;
                    //       });
                    //     }, //doesnt work
                    //     onPanDown: (details) => print('tdgreen'),
                    //     child: Container(
                    //       height: 100,
                    //       width: 100,
                    //       color: Colors.red,
                    //     ),
                    //   ),
                    // ),
                    SafeArea(child: Stack(children: [...notifier.loveStreamer(emojiController)]))
                  ],
                ),
          onWillPop: () async {
            notifier.destoryPusher();
            notifier.dispose();
            return true;
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     notifier.makeItems(emojiController);
        //   },
        //   child: Icon(Icons.favorite),
        // ),
        // bottomSheet: _buildBottomSheet(state, viewService, dispatch),
      ),
    );
  }

  int a = 0;

  final _debouncer = Debouncer(milliseconds: 2000);

  Widget prepare({String? titile}) {
    return Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      color: kHyppeTransparent,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          titile ?? "Please Wait",
          style: const TextStyle(
            color: kHyppeTextPrimary,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget startCounting(int time) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.black.withOpacity(0.3),
        ),
        child: Align(
          alignment: Alignment.center,
          child: CustomTextWidget(
              textToDisplay: time.toString(),
              textStyle: TextStyle(
                color: kHyppeTextPrimary,
                fontSize: 80,
              )),
        ),
      ),
    );
  }

  Widget _buildPreviewWidget(BuildContext context, StreamerNotifier notifier) {
    var x = 0.0;
    var y = 0.0;
    var width = MediaQuery.of(context).size.width;
    var height = 1000.0;

    // AlivcPusherPreviewType viewType;
    // if (Platform.isAndroid) {
    //   if (notifier.livePushMode == 0) {
    //     viewType = AlivcPusherPreviewType.base;
    //   } else {
    //     viewType = AlivcPusherPreviewType.push;
    //   }
    // } else {
    //   viewType = AlivcPusherPreviewType.push;
    // }
    // viewType = AlivcPusherPreviewType.base;

    // AlivcPusherPreview pusherPreviewView = AlivcPusherPreview(
    //   viewType: viewType,
    //   onCreated: (id) async {
    //     // await Future.delayed(const Duration(milliseconds: 500));
    //     notifier.previewCreated();
    //   },
    //   x: x,
    //   y: y,
    //   width: width,
    //   height: height,
    // );
    return Positioned(
      child: Container(color: Colors.black, width: width, height: height, child: pusherPreviewView),
    );
  }
}
