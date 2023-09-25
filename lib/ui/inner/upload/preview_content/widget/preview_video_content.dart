import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
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
          try{
            if (notifier.isForcePaused) {
              notifier.betterPlayerController?.pause();
            }
          }catch(e){
            e.logger();
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

        return Stack(
          children: [
            notifier.isLoadingBetterPlayer
                ? Center(child: Container())
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
                            child: Material(
                              child: !notifier.isLoadVideo
                                  ? Center(
                                      child: Platform.isAndroid
                                          ? AspectRatio(
                                              aspectRatio: notifier.betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 1,
                                              child: BetterPlayer(controller: notifier.betterPlayerController!),
                                            )
                                          : BetterPlayer(controller: notifier.betterPlayerController!),
                                    )
                                  : const Center(
                                      child: CustomLoading(),
                                    ),
                            ),
                          )
                        : const Center(
                            child: CustomLoading(),
                          ),
                if (notifier.fixSelectedMusic != null)
                  Positioned(
                    top: notifier.featureType == FeatureType.story ||
                        notifier.featureType == FeatureType.diary ? 16 : 96,
                    left: 52,
                    child: MusicStatusSelected(
                      music: notifier.fixSelectedMusic!,
                      isPlay: false,
                      onClose: () {
                        notifier.setDefaultVideo(context);
                      },
                    ),
                  ),
                for (var i = 0; i < notifier.onScreenStickers.length; i++) notifier.onScreenStickers[i],
                Visibility(
                  visible: notifier.isDragging,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 86,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomIconWidget(
                            defaultColor: false,
                            color: notifier.isDeleteButtonActive ? Colors.red : null,
                            iconData: "${AssetPath.vectorPath}circle_delete.svg",
                          ),
                          const SizedBox(height: 4),
                          CustomTextWidget(
                            textToDisplay: notifier.language.delete ?? 'delete',
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!notifier.isDragging)
                  Positioned(
                    right: 16,
                    bottom: context.getHeight() * 0.4,
                    child: Column(
                      children: [
                        InkWell(
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        twentyFourPx,
                        if (notifier.featureType == FeatureType.story || notifier.featureType == FeatureType.diary)
                        InkWell(
                          onTap: () async {
                            ShowBottomSheet.onShowSticker(context: context, whenComplete: () {
                              notifier.stickerSearchActive = false;
                              notifier.stickerSearchText = '';
                              notifier.stickerTextController.text = '';
                            });
                            notifier.getSticker(context, index: notifier.stickerTabIndex);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              CustomIconWidget(
                                defaultColor: false,
                                iconData: "${AssetPath.vectorPath}circle_sticker.svg",
                              ),
                              fourPx,
                              CustomTextWidget(
                                maxLines: 1,
                                textToDisplay: 'Stiker',
                                textAlign: TextAlign.left,
                                textStyle:  TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!(notifier.betterPlayerController?.isPlaying() ?? false))
                    const Center(
                      child: CustomIconWidget(
                        defaultColor: false,
                        iconData: "${AssetPath.vectorPath}pause.svg",
                      ),
                    )
          ],
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
