import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

import 'package:better_player/better_player.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';

import '../../../../../core/services/route_observer_service.dart';
import '../../../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import '../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../constant/widget/custom_text_widget.dart';
import 'music_status_selected_widget.dart';

class PreviewVideoContent extends StatefulWidget {
  PreviewVideoContent({Key? key});
  @override
  _PreviewVideoContentState createState() => _PreviewVideoContentState();
}

class _PreviewVideoContentState extends State<PreviewVideoContent> with RouteAware, AfterFirstLayoutMixin {
  BetterPlayerController? _videoPlayerController;
  double _x = 0;
  double _y = 0;

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    print('initState PreviewVideoContent');
    final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
    notifier.initVideoPlayer(context, isSaveDefault: true);
    _videoPlayerController = notifier.betterPlayerController;
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void didPop() {
    print('didPop PreviewVideoContent');
    super.didPop();
  }

  // @override
  // void didPush() {
  //   Future.delayed(Duration(seconds: 1), (){
  //     print('didPush isOnHomeScreen ${!SharedPreference().readStorage(SpKeys.isOnHomeScreen)}');
  //     SharedPreference().writeStorage(SpKeys.isOnHomeScreen, !SharedPreference().readStorage(SpKeys.isOnHomeScreen));
  //   });
  //   super.didPush();
  // }

  @override
  void didPopNext() {
    print('didPopNext PreviewVideoContent');
    final notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
    if (notifier.defaultPath != notifier.fileContent?[notifier.indexView]) {
      notifier.initVideoPlayer(context);
    } else {
      notifier.setDefaultVideo(context);
    }
    super.didPopNext();
  }

  @override
  void didPushNext() {
    print('didPushNext PreviewVideoContent');
    super.didPushNext();
  }

  @override
  void deactivate() {
    print('deactivate PreviewVideoContent');
    super.deactivate();
  }

  @override
  void didPush() {
    print('didPush PreviewVideoContent');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final notifier = context.read<PreviewContentNotifier>();

    return Consumer<PreviewContentNotifier>(
      builder: (_, notifier, __) {
        Future.delayed(Duration.zero, () {
          if (notifier.isForcePaused) {
            notifier.betterPlayerController?.pause();
          }
        });

        // if (notifier.betterPlayerController == null) {
        //   return const Center(
        //     child: CustomLoading(),
        //   );
        // }
        if (!notifier.isLoadingBetterPlayer) {
          final height = notifier.betterPlayerController?.videoPlayerController?.value.size?.height;
          final width = notifier.betterPlayerController?.videoPlayerController?.value.size?.width;
          print('PreviewVideoContent size video: $height : $width');
          notifier.setWidth(width?.toInt());
          notifier.setHeight(height?.toInt());
        }
        print('isloading ${notifier.isLoadingBetterPlayer}');
        print('isloading ${notifier.errorMessage}');

        return notifier.isLoadingBetterPlayer
            ? Center(
                child: Container(),
              )
            : notifier.errorMessage != ''
                ? Center(child: Text(notifier.errorMessage))
                : notifier.betterPlayerController?.isVideoInitialized() ?? false
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            if (notifier.betterPlayerController?.isPlaying() ?? false) {
                              notifier.betterPlayerController?.pause();
                            } else {
                              notifier.betterPlayerController?.play();
                            }
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Material(
                              child: !notifier.isLoadVideo
                                  ? Center(
                                      child: Platform.isAndroid
                                          ? AspectRatio(
                                              child: BetterPlayer(controller: notifier.betterPlayerController!),
                                              aspectRatio: notifier.betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 1,
                                            )
                                          : BetterPlayer(controller: notifier.betterPlayerController!),
                                    )
                                  : const Center(
                                      child: CustomLoading(),
                                    ),
                            ),
                            if (notifier.fixSelectedMusic != null)
                              Positioned(
                                top: _y == 0 ? (context.getHeight() / 2) : _y,
                                left: _x == 0 ? (context.getWidth() * 0.1) : _x,
                                child: Draggable(
                                  childWhenDragging: const SizedBox.shrink(),
                                  feedback: MusicStatusSelected(
                                    music: notifier.fixSelectedMusic!,
                                    onClose: () {
                                      notifier.setDefaultVideo(context);
                                    },
                                    isDrag: true,
                                    isPlay: false,
                                  ),
                                  child: MusicStatusSelected(
                                    music: notifier.fixSelectedMusic!,
                                    onClose: () {
                                      notifier.setDefaultVideo(context);
                                    },
                                    isPlay: false,
                                  ),
                                  onDragEnd: (dragDetail) {
                                    notifier.audioPreviewPlayer.resume();
                                    setState(() {
                                      _x = dragDetail.offset.dx;
                                      _y = dragDetail.offset.dy;
                                    });
                                  },
                                  onDragStarted: () {
                                    notifier.audioPreviewPlayer.pause();
                                  },
                                ),
                              ),
                            // Positioned.fill(
                            //   child: Align(
                            //     alignment: Alignment.center,
                            //     child: Container(
                            //       margin: const EdgeInsets.only(left: 70, right: 70),
                            //       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            //       decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: const BorderRadius.all(Radius.circular(16))),
                            //       child: Row(
                            //         crossAxisAlignment: CrossAxisAlignment.center,
                            //         mainAxisAlignment: MainAxisAlignment.start,
                            //         children: [
                            //           InkWell(
                            //             onTap: () {
                            //               notifier.setDefaultVideo(context);
                            //             },
                            //             child: const CustomIconWidget(
                            //               height: 20,
                            //               width: 20,
                            //               iconData: "${AssetPath.vectorPath}close_ads.svg",
                            //             ),
                            //           ),
                            //           fourPx,
                            //           Container(
                            //             width: 1,
                            //             height: 13,
                            //             color: kHyppeGrey,
                            //           ),
                            //           sixPx,
                            //           Expanded(
                            //             child: CustomTextWidget(
                            //               textOverflow: TextOverflow.ellipsis,
                            //               maxLines: 3,
                            //               textToDisplay: '${notifier.fixSelectedMusic?.musicTitle} - ${notifier.fixSelectedMusic?.artistName}',
                            //               textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                            //             ),
                            //           )
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Positioned(
                              right: 16,
                              bottom: context.getHeight() * 0.4,
                              child: InkWell(
                                onTap: () {
                                  notifier.betterPlayerController?.pause();
                                  ShowBottomSheet.onChooseMusic(context);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CustomIconWidget(
                                      defaultColor: false,
                                      iconData: "${AssetPath.vectorPath}circle_music.svg",
                                    ),
                                    fourPx,
                                    CustomTextWidget(
                                        maxLines: 1,
                                        textToDisplay: notifier.language.music ?? '',
                                        textAlign: TextAlign.left,
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 14,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                            if (!(notifier.betterPlayerController?.isPlaying() ?? false))
                              const CustomIconWidget(
                                defaultColor: false,
                                iconData: "${AssetPath.vectorPath}pause.svg",
                              )
                          ],
                        ),
                      )
                    : const Center(
                        child: CustomLoading(),
                      );
      },
    );
  }

  @override
  void dispose() {
    print('PreviewVideoContent is disposed');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    if (notifier.betterPlayerController != null) {
      notifier.betterPlayerController!.dispose();
    }
    notifier.defaultPath = null;
    notifier.disposeMusic();

    CustomRouteObserver.routeObserver.unsubscribe(this);
    super.dispose();
  }
}
