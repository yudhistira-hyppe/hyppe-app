import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_livepush_plugin/live_pusher_preview.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/beforelive.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/love_lottie.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/pauseLive.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/widget/streamer.dart';
import 'package:hyppe/ux/routing.dart';
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

class _StreamerScreenState extends State<StreamerScreen> with TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  bool isloading = true;
  FocusNode commentFocusNode = FocusNode();
  AlivcPusherPreview? pusherPreviewView;

  bool isLiked = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    isactivealiplayer = true;
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro.requestPermission(context);
      streampro.init(context, mounted);

      commentFocusNode.addListener(() {
        // print("Has focus: ${commentFocusNode.hasFocus}");
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
    // print("====dispose stremer ===");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    context.read<StreamerNotifier>().inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // var streampro = Provider.of<StreamerNotifier>(context, listen: false);
    if (state == AppLifecycleState.inactive) {
      print("========= Streamer AppLifecycleState.inactive ==========");
    }
    if (state == AppLifecycleState.resumed) {
      print("========= Streamer AppLifecycleState.resumed ==========");
    }

    if (state == AppLifecycleState.paused) {
      // Minimize aplication
      print("========= Streamer AppLifecycleState.paused ==========");
      // streampro.pauseLive(context, mounted);
    }

    if (state == AppLifecycleState.detached) {
      print("========= Streamer AppLifecycleState.detached ==========");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: WillPopScope(
          child: notifier.isloading
              ? SizedBox(
                  height: SizeConfig.screenHeight,
                  child: Stack(
                    children: [
                      const Center(child: CustomLoading()),
                      Align(
                        alignment: Alignment.topRight,
                        child: SafeArea(
                          child: CustomIconButtonWidget(
                            padding: const EdgeInsets.all(0),
                            alignment: Alignment.center,
                            iconData: "${AssetPath.vectorPath}close.svg",
                            defaultColor: false,
                            onPressed: () {
                              Routing().moveBack();
                            },
                          ),
                        ),
                      )
                    ],
                  ))
              : Stack(
                  children: [
                    _buildPreviewWidget(context, notifier),
                    Positioned.fill(
                      bottom: -90,
                      right: 10,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 70,
                          child: Stack(
                            children: notifier.animationIndexes.map((e) {
                              return LoveLootie(
                                onAnimationFinished: () {
                                  // notifier.removeAnimation(e);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    notifier.isloadingPreview
                        ? SizedBox(
                            height: SizeConfig.screenHeight,
                            child: Stack(
                              children: [
                                const Center(child: CustomLoading()),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: SafeArea(
                                    child: CustomIconButtonWidget(
                                      padding: const EdgeInsets.all(0),
                                      alignment: Alignment.center,
                                      iconData: "${AssetPath.vectorPath}close.svg",
                                      defaultColor: false,
                                      onPressed: () {
                                        Routing().moveBack();
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ))
                        : notifier.statusLive == StatusStream.offline
                            ? BeforeLive(mounted: mounted)
                            : notifier.statusLive == StatusStream.prepare
                                ? prepare()
                                : notifier.statusLive == StatusStream.standBy
                                    ? startCounting(notifier.timeReady, notifier, tn)
                                    : notifier.statusLive == StatusStream.ready
                                        ? prepare(titile: notifier.tn?.liveVideoHasStarted ?? '')
                                        : Container(),
                    if (notifier.isPause) PauseLive(notifier: notifier),
                    if (notifier.statusLive == StatusStream.ready || notifier.statusLive == StatusStream.online) StreamerWidget(commentFocusNode: commentFocusNode),
                    // StreamerWidget(commentFocusNode: commentFocusNode),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: GestureDetector(
                    //     onTap: () {
                    //       notifier.zoom();
                    //       // a++;
                    //       // _debouncer.run(() {
                    //       //   print(a);
                    //       //   a = 0;
                    //       // });
                    //     }, //doesnt work
                    //     onPanDown: (details) => print('tdgreen'),
                    //     child: Container(
                    //       height: 100,
                    //       width: 100,
                    //       color: Colors.red,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
          onWillPop: () async {
            if (notifier.statusLive == StatusStream.offline) {
              Routing().moveBack();
              notifier.destoryPusher();
            } else if (notifier.statusLive == StatusStream.standBy) {
              notifier.cancelLive(context, mounted);
              notifier.destoryPusher();
            } else {
              await ShowGeneralDialog.generalDialog(
                context,
                titleText: tn.endofLIVEBroadcast,
                bodyText: tn.areYouSureYouWantToEndTheLIVEBroadcast,
                maxLineTitle: 1,
                maxLineBody: 4,
                functionPrimary: () async {
                  notifier.endLive(context, context.mounted);
                },
                functionSecondary: () {
                  Routing().moveBack();
                },
                titleButtonPrimary: "${tn.endNow}",
                titleButtonSecondary: "${tn.cancel}",
                barrierDismissible: true,
                isHorizontal: false,
              );
            }

            // notifier.destoryPusher();
            // notifier.dispose();
            return false;
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

  // final _debouncer = Debouncer(milliseconds: 2000);

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

  Widget startCounting(int time, StreamerNotifier notifier, LocalizationModelV2 tn) {
    return Stack(
      children: [
        Align(
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
                  textStyle: const TextStyle(
                    color: kHyppeTextPrimary,
                    fontSize: 80,
                  )),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              notifier.cancelLive(context, mounted);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 100),
              width: 50,
              height: 50,
              color: Colors.transparent,
              child: Center(
                  child: Text(
                tn.cancel ?? "Batal",
                style: const TextStyle(color: Colors.white),
              )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewWidget(BuildContext context, StreamerNotifier notifier) {
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
