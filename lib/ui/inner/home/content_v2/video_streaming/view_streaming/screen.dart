import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/arguments/view_streaming_argument.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/love_lottie.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/gift_deluxe.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/love_lottie.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/over_live_streaming.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/pauseLive.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/title_view_live.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/widget/viewer_comment.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../constant/widget/custom_loading.dart';
import '../streamer/screen.dart';
import '../streamer/widget/love_lottielarge.dart';

class ViewStreamingScreen extends StatefulWidget {
  final ViewStreamingArgument args;

  const ViewStreamingScreen({super.key, required this.args});

  @override
  State<ViewStreamingScreen> createState() => _ViewStreamingScreenState();
}

class _ViewStreamingScreenState extends State<ViewStreamingScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  FocusNode commentFocusNode = FocusNode();

  final debouncer = Debouncer(milliseconds: 2000);

  var loadLaunch = false;

  bool isMute = false;

  bool loading = true;
  ViewStreamingNotifier? notifier;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    notifier = (Routing.navigatorKey.currentContext ?? context).read<ViewStreamingNotifier>();
    notifier?.initViewStreaming(widget.args.data);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      loading = false;
      setState(() {});
      commentFocusNode.addListener(() {
        debugPrint("Has focus: ${commentFocusNode.hasFocus}");
      });
      await notifier?.requestPermission(context);
      await notifier?.startViewStreaming(Routing.navigatorKey.currentContext ?? context, mounted, widget.args.data);
      WakelockPlus.enable();
      if (!mounted) return;

      // await notifier.initAgora(context, mounted, widget.args.data);
      SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
      WidgetsBinding.instance.addObserver(this);
      loading = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    WakelockPlus.disable();
    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
    context.read<ViewStreamingNotifier>().disposeAgora();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // var streampro = Provider.of<StreamerNotifier>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      print("========= Streamer AppLifecycleState.inactive ==========");
      // context.read<ViewStreamingNotifier>().exitStreaming(context, widget.args.data).whenComplete(() async {
      //   await context.read<ViewStreamingNotifier>().destoryPusher();
      //   Routing().moveBack();
      // });
    }
    if (state == AppLifecycleState.resumed) {
      notifier?.engine.muteAllRemoteAudioStreams(false);
      print("========= Streamer AppLifecycleState.resumed ==========");
    }

    if (state == AppLifecycleState.paused) {
      // Minimize aplication
      print("========= Streamer AppLifecycleState.paused ==========");
      notifier?.engine.muteAllRemoteAudioStreams(true);

      // streampro.pauseLive(context, mounted);
    }

    if (state == AppLifecycleState.detached) {
      print("========= Streamer AppLifecycleState.detached ==========");
    }
  }

  final _debouncer = Debouncer(milliseconds: 2000);
  @override
  Widget build(BuildContext context) {
    return Consumer<ViewStreamingNotifier>(builder: (_, notifier, __) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          child: SizedBox(
            width: SizeConfig.screenWidth,
            height: MediaQuery.of(context).size.height,
            child: notifier.isOver
                ? OverLiveStreaming(
                    data: widget.args.data,
                    notifier: notifier,
                  )
                : Stack(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          commentFocusNode.unfocus();
                        },
                        onDoubleTapDown: (details) {
                          var position = details.globalPosition;
                          notifier.positionDxDy = position;
                        },
                        onDoubleTap: () {
                          notifier.likeAddTapScreen();
                          _debouncer.run(() {
                            notifier.sendLikeTapScreen(context, notifier.streamerData!);
                          });
                        },
                        child: Container(
                          color: Colors.black,
                          width: SizeConfig.screenWidth,
                          height: SizeConfig.screenHeight,
                          child: notifier.remoteUid != -1
                              ? AspectRatio(
                                  aspectRatio: MediaQuery.of(context).devicePixelRatio,
                                  child: AgoraVideoView(
                                    controller: VideoViewController.remote(
                                      rtcEngine: notifier.engine,
                                      canvas: VideoCanvas(
                                        uid: notifier.remoteUid,
                                        renderMode: RenderModeType.renderModeHidden,
                                      ),
                                      connection: RtcConnection(channelId: widget.args.data.sId ?? ''),
                                    ),
                                  ),
                                )
                              : const Align(
                                  alignment: Alignment.center,
                                  child: CustomLoading(),
                                ),
                        ),
                      ),
                      if ((notifier.statusAgora == RemoteVideoState.remoteVideoStateStopped || notifier.statusAgora == RemoteVideoState.remoteVideoStateStopped) &&
                          (notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted || notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonSdkInBackground))
                        PauseLiveView(data: widget.args.data),

                      Positioned.fill(
                        bottom: -60,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 70,
                            child: Stack(
                              children: notifier.animationIndexes.map((e) {
                                return LoveLootie(
                                  onAnimationFinished: () {},
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: notifier.positionDxDy.dy - 410,
                        left: notifier.positionDxDy.dx - 90,
                        child: SizedBox(
                          width: 180,
                          child: Stack(
                            children: notifier.likeListTapScreen.map((e) {
                              return LoveLootieLarge(
                                onAnimationFinished: () {
                                  // notifier.removeAnimation(e);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom: -60,
                        right: 0,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            width: 70,
                            child: Stack(
                              children: notifier.likeList.map((e) {
                                return LoveSingleLootie(
                                  onAnimationFinished: () {
                                    // notifier.removeAnimation(e);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      const Positioned.fill(child: GiftDeluxe()),
                      //Buffering
                      if (notifier.resionAgora == RemoteVideoStateReason.remoteVideoStateReasonNetworkCongestion)
                        const Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  strokeWidth: 3.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "Buffering",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Positioned(
                      //   top: 100,
                      //   left: 100,
                      //   child: GestureDetector(
                      //       onTap: () {
                      //         print("disini");
                      //       },
                      //       child: Container(color: Colors.red, width: 100, height: 100, child: Align(alignment: Alignment.center, child: Text('${MediaQuery.of(context).size.height} ')))),
                      // ),

                      TitleViewLive(
                        data: widget.args.data,
                        totLikes: notifier.totLikes,
                        totViews: notifier.totViews,
                        dataStream: notifier.dataStreaming,
                      ),
                      Positioned(
                        bottom: 36,
                        left: 16,
                        right: 16,
                        child: ViewerComment(
                          commentFocusNode: commentFocusNode,
                          data: widget.args.data,
                        ),
                      )
                    ],
                  ),
          ),
          onWillPop: () async {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
            context.read<ViewStreamingNotifier>().exitStreaming(context, widget.args.data).whenComplete(() async {
              await context.read<ViewStreamingNotifier>().destoryPusher();
              Routing().moveBack();
            });
            return false;
          },
        ),
      );
    });
  }
}
