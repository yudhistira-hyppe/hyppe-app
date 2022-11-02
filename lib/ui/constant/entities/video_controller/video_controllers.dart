// import 'dart:async';
// import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/constants/size_widget.dart';
// import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
// import 'package:hyppe/core/constants/thumb/profile_image.dart';
// // import 'package:hyppe/core/constants/utils.dart';
// import 'package:hyppe/core/models/collection/posts/content/content_data.dart';
// import 'package:hyppe/core/services/system.dart';
// import 'package:hyppe/ui/constant/entities/like/notifier.dart';
// import 'package:hyppe/ui/constant/entities/playlist/notifier.dart';
// // import 'package:hyppe/ui/constant/entities/video_controller/widget/playback_speed_dialog.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
// import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
// import 'package:hyppe/ui/constant/widget/custom_loading.dart';
// import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
// import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
// import 'package:hyppe/ui/constant/widget/profile_component.dart';
// import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
// // import 'package:hyppe/ui/inner/home/content/see_all/notifier.dart';
// // import 'package:hyppe/ui/inner/home/content/vid/notifier.dart';
// import 'package:hyppe/ux/path.dart';
// import 'package:hyppe/ux/routing.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart';
// // ignore: implementation_imports
// import 'package:chewie/src/material/material_progress_bar.dart';
// import 'package:hyppe/ui/constant/entities/follow/notifier.dart';

// // listenable value
// ValueNotifier<bool> videoPlay = ValueNotifier<bool>(false);

// // TODO(Hendi Noviansyah): check if this class is still needed
// class VideoControllers extends StatefulWidget {
//   final bool isSeeAll;
//   final ContentData? data;
//   final Map<String, dynamic>? arguments;

//   const VideoControllers({Key? key, this.data, this.isSeeAll = false, this.arguments}) : super(key: key);

//   @override
//   _VideoControllersState createState() => _VideoControllersState();
// }

// class _VideoControllersState extends State<VideoControllers> {
//   static final _system = System();
//   static final _bottomSheet = ShowBottomSheet();

//   VideoPlayerValue? _latestValue;
//   bool _hideStuff = true;
//   Timer? _hideTimer;
//   Timer? _initTimer;
//   Timer? _showAfterExpandCollapseTimer;
//   bool _dragging = false;
//   bool _displayTapped = false;
//   ValueNotifier<bool> _forwardAction = ValueNotifier<bool>(false);
//   ValueNotifier<bool> _replayAction = ValueNotifier<bool>(false);

//   final barHeight = 48.0;

//   late VideoPlayerController controller;
//   ChewieController? chewieController;

//   @override
//   void dispose() {
//     _dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     final _oldController = chewieController;
//     chewieController = ChewieController.of(context);
//     controller = chewieController!.videoPlayerController;

//     if (_oldController != chewieController) {
//       _dispose();
//       _initialize();
//     }

//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);
//     if (_latestValue.hasError && !controller.value.isInitialized) {
//       return chewieController.errorBuilder != null
//           ? chewieController.errorBuilder!(context, chewieController.videoPlayerController.value.errorDescription!)
//           : Container(
//               width: SizeConfig.screenWidth,
//               height: SizeWidget().calculateSize(SizeWidget.centerLongVideoFrame, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
//               child: CustomErrorWidget(
//                 errorType: null,
//                 padding: EdgeInsets.zero,
//                 function: () => _playPause(),
//               ),
//             );
//     }

//     return MouseRegion(
//       onHover: (_) {
//         _cancelAndRestartTimer();
//       },
//       child: GestureDetector(
//         onTap: () => _cancelAndRestartTimer(),
//         child: AbsorbPointer(
//           absorbing: _hideStuff,
//           child: Stack(
//             children: [
//               AnimatedOpacity(
//                   child: Container(color: Colors.black.withOpacity(0.5)),
//                   duration: const Duration(milliseconds: 300),
//                   opacity: _latestValue != null && !_dragging && !_latestValue.isBuffering && !_latestValue.isPlaying || !_hideStuff ? 1.0 : 0.0),
//               Column(
//                 children: <Widget>[
//                   // GestureDetector(
//                   //   onTap: () {
//                   //     if (!chewieController.isFullScreen) {
//                   //       if (!widget.isSeeAll) {
//                   //         if (!_latestValue.isPlaying) {
//                   //           if (!_hideStuff) {
//                   //             if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
//                   //             context.read<PreviewVidNotifier>().navigateToSeeAllScreen(context, widget.data, _latestValue.position);
//                   //           }
//                   //         }
//                   //       }
//                   //     }
//                   //   },
//                   //   child: _buildTopControl(),
//                   // ),
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                             child: GestureDetector(
//                                 onTap: () {
//                                   if (!chewieController!.isFullScreen) {
//                                     if (!widget.isSeeAll) {
//                                       if (!_latestValue.isPlaying) {
//                                         if (!_hideStuff) {
//                                           if (context.read<OverlayHandlerProvider>().overlayActive)
//                                             context.read<OverlayHandlerProvider>().removeOverlay(context);
//                                           // context.read<PreviewVidNotifier>().navigateToSeeAllScreen(context, widget.data, _latestValue.position);
//                                         }
//                                       }
//                                     }
//                                   }
//                                 },
//                                 onDoubleTap: () {
//                                   if (chewieController!.isFullScreen && (_latestValue.position.inSeconds - 10) >= Duration.zero.inSeconds) {
//                                     _replayAction.value = true;
//                                     controller.seekTo(Duration(seconds: _latestValue.position.inSeconds - 10));
//                                   } else {
//                                     print('do nothing');
//                                   }
//                                 },
//                                 child: Container(color: Colors.transparent))),
//                         Expanded(
//                             child: GestureDetector(
//                                 onTap: () {
//                                   if (!chewieController.isFullScreen) {
//                                     if (!widget.isSeeAll) {
//                                       if (!_latestValue.isPlaying) {
//                                         if (!_hideStuff) {
//                                           if (context.read<OverlayHandlerProvider>().overlayActive)
//                                             context.read<OverlayHandlerProvider>().removeOverlay(context);
//                                           // context.read<PreviewVidNotifier>().navigateToSeeAllScreen(context, widget.data, _latestValue.position);
//                                         }
//                                       }
//                                     }
//                                   }
//                                 },
//                                 onDoubleTap: () {
//                                   if (chewieController!.isFullScreen && (_latestValue.position.inSeconds + 10) <= _latestValue.duration.inSeconds) {
//                                     _forwardAction.value = true;
//                                     controller.seekTo(Duration(seconds: _latestValue.position.inSeconds + 10));
//                                   } else {
//                                     print('do nothing');
//                                   }
//                                 },
//                                 child: Container(color: Colors.transparent)))
//                       ],
//                     ),
//                   ),
//                   if (_latestValue.isPlaying && _hideStuff)
//                     VideoProgressIndicator(chewieController!.videoPlayerController,
//                         allowScrubbing: false,
//                         colors: VideoProgressColors(
//                             bufferedColor: Theme.of(context).textTheme.caption!.color!,
//                             playedColor: Theme.of(context).colorScheme.primaryVariant,
//                             backgroundColor: Theme.of(context).textTheme.caption!.color!.withOpacity(0.7)))
//                   else
//                     AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 250),
//                         child: !chewieController!.isPlaying && _latestValue.position.inSeconds < 1
//                             ? _buildVideoDescription()
//                             : _buildBottomControl(context),
//                         transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child, alignment: Alignment.bottomCenter))
//                 ],
//               ),
//               Center(child: _latestValue.isBuffering ? CustomLoading() : _buildHitArea()),
//               ValueListenableBuilder<bool>(
//                 valueListenable: _forwardAction,
//                 builder: (_, value, __) {
//                   return AnimatedOpacity(
//                     duration: const Duration(milliseconds: 200),
//                     opacity: value ? 1 : 0,
//                     onEnd: () => Timer(const Duration(milliseconds: 500), () => _forwardAction.value = false),
//                     child: Align(
//                         alignment: const Alignment(0.5, 0.0),
//                         child: RotatedBox(
//                             quarterTurns: 3, child: CustomIconWidget(iconData: '${AssetPath.vectorPath}forwardAndReplay.svg', defaultColor: false))),
//                   );
//                 },
//               ),
//               ValueListenableBuilder<bool>(
//                 valueListenable: _replayAction,
//                 builder: (_, value, __) {
//                   return AnimatedOpacity(
//                     duration: const Duration(milliseconds: 200),
//                     opacity: value ? 1 : 0,
//                     onEnd: () => Timer(const Duration(milliseconds: 500), () => _replayAction.value = false),
//                     child: Align(
//                         alignment: const Alignment(-0.5, 0.0),
//                         child: RotatedBox(
//                             quarterTurns: 1, child: CustomIconWidget(iconData: '${AssetPath.vectorPath}forwardAndReplay.svg', defaultColor: false))),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _dispose() {
//     controller.removeListener(_updateState);
//     _hideTimer?.cancel();
//     _initTimer?.cancel();
//     _showAfterExpandCollapseTimer?.cancel();
//   }

//   void _cancelAndRestartTimer() {
//     _hideTimer?.cancel();
//     _startHideTimer();

//     setState(() {
//       _hideStuff = false;
//       _displayTapped = true;
//     });
//   }

//   Future<void> _initialize() async {
//     controller.addListener(_updateState);

//     _updateState();

//     if ((controller.value.isPlaying) || chewieController!.autoPlay) {
//       _startHideTimer();
//     }

//     if (chewieController!.showControlsOnInitialize) {
//       _initTimer = Timer(const Duration(milliseconds: 200), () {
//         setState(() {
//           _hideStuff = false;
//         });
//       });
//     }
//   }

//   void _onExpandCollapse() {
//     if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);

//     setState(() {
//       _hideStuff = true;

//       /// SOLVED : cannot back to normal view when in the landscape mode
//       if (chewieController!.isFullScreen) {
//         SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//       }

//       chewieController!.toggleFullScreen();

//       if (chewieController!.isFullScreen) {
//         SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
//       }

//       _showAfterExpandCollapseTimer = Timer(const Duration(milliseconds: 300), () => setState(() => _cancelAndRestartTimer()));
//     });
//   }

//   void _playPause() async {
//     final isFinished = _latestValue.position >= _latestValue.duration;

//     if (!controller.value.isInitialized) await Future.delayed(const Duration(milliseconds: 500));

//     setState(() {
//       if (controller.value.isPlaying) {
//         _hideStuff = false;
//         _hideTimer?.cancel();
//         controller.pause();
//       } else {
//         _cancelAndRestartTimer();

//         if (!controller.value.isInitialized) {
//           _system.checkConnections().then((value) {
//             if (value) {
//               controller.initialize().then((_) => controller.play());
//             } else {
//               _bottomSheet.onShowColouredSheet(
//                 context,
//                 'Please check your connection',
//                 color: kHyppeDanger,
//               );
//             }
//           });
//         } else {
//           if (isFinished) controller.seekTo(const Duration());
//           controller.play();
//         }
//       }
//     });
//   }

//   void _startHideTimer() {
//     _hideTimer = Timer(const Duration(seconds: 3), () => setState(() => _hideStuff = true));
//   }

//   void _updateState() => setState(() => _latestValue = controller.value);

//   Widget _buildHitArea() {
//     return GestureDetector(
//         onTap: () {
//           if (_latestValue != null && _latestValue.isPlaying) {
//             if (_displayTapped) {
//               setState(() => _hideStuff = true);
//             } else {
//               _cancelAndRestartTimer();
//             }
//           } else {
//             // _playPause();

//             setState(() => _hideStuff = true);
//           }
//         },
//         child: UnconstrainedBox(
//           child: Container(
//               child: AnimatedOpacity(
//                   opacity: _latestValue != null && !_dragging && !_latestValue.isBuffering && !_latestValue.isPlaying || !_hideStuff ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: GestureDetector(
//                       onTap: () => _playPause(),
//                       onDoubleTap: null,
//                       child: CustomIconWidget(
//                           iconData: chewieController!.isPlaying ? '${AssetPath.vectorPath}play.svg' : '${AssetPath.vectorPath}pause.svg',
//                           defaultColor: false)))),
//         ));
//   }

//   Widget _buildTopControl() {
//     return AnimatedOpacity(
//         opacity: _latestValue != null && !_dragging && !_hideStuff || !_latestValue.isPlaying ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 300),
//         child: Container(
//             width: SizeConfig.screenWidth,
//             padding: const EdgeInsets.only(left: 16.0, top: 8.0),
//             child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
//               _buildProfilePicture(),
//               Expanded(child: Container(height: 40, child: CustomTextWidget(textToDisplay: ''))),
//               _buildTopRightControl()
//             ])));
//   }

//   AnimatedOpacity _buildBottomControl(BuildContext context) {
//     final iconColor = Theme.of(context).textTheme.button!.color;

//     return AnimatedOpacity(
//       opacity: _hideStuff ? 0.0 : 1.0,
//       duration: const Duration(milliseconds: 300),
//       child: Container(
//         height: SizeWidget().calculateSize(barHeight, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
//         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//         child: Row(
//           children: <Widget>[
//             _buildPosition(iconColor),
//             _buildProgressBar(),
//             // _buildSpeedButton(),
//             _buildExpandButton()
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoDescription() {
//     return Column(children: [
//       !widget.isSeeAll
//           ? Container(
//               padding: const EdgeInsets.only(left: 16, right: 8),
//               child: Row(children: <Widget>[_buildTotalVideoDuration(), fourPx, _buildTotalVideoLike()]))
//           : SizedBox.shrink(),
//       Container(
//           padding: const EdgeInsets.only(left: 16, right: 8),
//           child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[_buildDescription(), _buildLikeButton()]))
//     ]);
//   }

//   Widget _buildLikeButton() {
//     return Consumer<LikeNotifier>(builder: (context, notifier, child) {
//       return CustomIconButtonWidget(
//           iconData: '${AssetPath.vectorPath}${widget.data!.isReacted == 0 ? 'none-like.svg' : 'liked.svg'}',
//           onPressed: () {
//             widget.data!.isReacted == 0 ? notifier.showReactionList(context, widget.data) : notifier.onLikeContent(context, data: widget.data!);
//           });
//     });
//   }

//   Widget _buildDescription() {
//     return Container(
//         width: 240,
//         child: CustomTextWidget(
//             maxLines: 2, textAlign: TextAlign.left, textStyle: Theme.of(context).textTheme.caption, textToDisplay: widget.data!.description!));
//   }

//   Widget _buildTotalVideoDuration() {
//     final position = _latestValue != null ? _latestValue.duration : Duration.zero;

//     return CustomBalloonWidget(
//         child: CustomTextWidget(textToDisplay: '${System().formatDuration(position.inSeconds)}', textStyle: Theme.of(context).textTheme.caption));
//   }

//   Widget _buildTotalVideoLike() {
//     return Consumer<LikeNotifier>(builder: (context, value, child) {
//       return CustomBalloonWidget(
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//         CustomIconWidget(iconData: '${AssetPath.vectorPath}like.svg', defaultColor: false, color: Theme.of(context).appBarTheme.iconTheme.color),
//         fourPx,
//         CustomTextWidget(textToDisplay: '${widget.data!.lCount}', textStyle: Theme.of(context).textTheme.caption)
//       ]));
//     });
//   }

//   Widget _buildProfilePicture() {
//     if (widget.isSeeAll) {
//       return CustomTextButton(
//           style: ButtonStyle(alignment: Alignment.centerLeft, padding: MaterialStateProperty.all(EdgeInsets.zero)),
//           onPressed: () {
//             if (widget.arguments != null && !widget.arguments!.containsKey('isSearch')) {
//               Routing().moveAndPop(lobby);
//             } else {
//               Routing().moveBack();
//             }
//           },
//           child: CustomIconWidget(
//               defaultColor: false, iconData: '${AssetPath.vectorPath}back-arrow.svg', color: Theme.of(context).appBarTheme.iconTheme.color));
//     }

//     return Consumer<FollowRequestUnfollowNotifier>(
//       builder: (_, __, child) => child!,
//       child: ProfileComponent(
//         haveStory: widget.data!.isHaveStory ?? false,
//         featureType: FeatureType.vid,
//         show: !widget.isSeeAll,
//         username: widget.data!.username,
//         following: widget.data!.isFollowing!,
//         isCelebrity: widget.data!.isCelebrity,
//         imageUrl: '${widget.data!.profilePic}$VERYBIG',
//         createdAt: '${System().readTimestamp(int.parse(widget.data!.createdAt!), context, fullCaption: true)}',
//         onTapOnProfileImage: () => !chewieController!.isFullScreen ? System().navigateToProfileScreen(context, widget.data) : null,
//         onFollow: () async => await context
//             .read<FollowRequestUnfollowNotifier>()
//             .followRequestUnfollowUser(context, fUserId: widget.data!.userID!, statusFollowing: StatusFollowing.rejected, currentValue: widget.data!),
//       ),
//     );
//   }

//   Widget _buildTopRightControl() {
//     return Container(
//         width: 100,
//         child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
//           if (!chewieController!.isFullScreen)
//             Container(
//                 height: 40,
//                 width: 40,
//                 child: CustomTextButton(
//                     style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.only(left: 0.0))),
//                     onPressed: () async {
//                       await controller.pause();
//                       context.read<PlaylistNotifier>().showMyPlaylistBottomSheet(context, index: 0, data: widget.data, featureType: FeatureType.vid);
//                     },
//                     child: CustomIconWidget(
//                         iconData: '${AssetPath.vectorPath}bookmark.svg',
//                         defaultColor: false,
//                         color: Theme.of(context).appBarTheme.iconTheme.color))),
//           Container(
//               height: 40,
//               width: 40,
//               child: CustomTextButton(
//                   onPressed: () async {
//                     // await controller.pause();
//                     // if (widget.isSeeAll && context.read<SeeAllNotifier>().isUserLogIn(context)) {
//                     //   // ShowBottomSheet.onShowOptionContent(
//                     //   //   context,
//                     //   //   arguments: widget.arguments,
//                     //   //   contentData: widget.data,
//                     //   //   captionTitle: HYPPEVID,
//                     //   //   contentIndex: context.read<SeeAllNotifier>().contentIndex,
//                     //   // );
//                     // } else {
//                     //   ShowBottomSheet.onShowReport(context,
//                     //       data: widget.data,
//                     //       reportType: ReportType.post,
//                     //       height: SizeConfig.screenHeight! * 0.5,
//                     //       fromLandscapeMode: chewieController!.isFullScreen);
//                     // }
//                   },
//                   style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.only(left: 0.0))),
//                   child: CustomIconWidget(
//                       iconData: '${AssetPath.vectorPath}more.svg', defaultColor: false, color: Theme.of(context).appBarTheme.iconTheme.color)))
//         ]));
//   }

//   GestureDetector _buildExpandButton() {
//     return GestureDetector(
//         onTap: _onExpandCollapse,
//         child: AnimatedOpacity(
//             opacity: _hideStuff ? 0.0 : 1.0,
//             duration: const Duration(milliseconds: 300),
//             child: Container(
//                 height: SizeWidget().calculateSize(barHeight, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
//                 child: Center(
//                     child: CustomIconWidget(
//                         iconData: '${AssetPath.vectorPath}fullscreen.svg',
//                         // height: chewieController!.isFullScreen ? 18 : null,
//                         // width: chewieController!.isFullScreen ? 18 : null,
//                         defaultColor: false,
//                         color: Theme.of(context).appBarTheme.iconTheme.color)))));
//   }

//   Widget _buildPosition(Color? iconColor) {
//     final position = _latestValue != null ? _latestValue.position : Duration.zero;

//     return CustomTextWidget(textToDisplay: '${System().formatDuration(position.inSeconds)}', textStyle: Theme.of(context).textTheme.caption);
//   }

//   Widget _buildProgressBar() {
//     return Expanded(
//         child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: MaterialVideoProgressBar(controller, onDragStart: () {
//               setState(() => _dragging = true);

//               _hideTimer?.cancel();
//             }, onDragEnd: () {
//               setState(() => _dragging = false);

//               _startHideTimer();
//             },
//                 colors: chewieController!.materialProgressColors ??
//                     ChewieProgressColors(
//                       bufferedColor: Theme.of(context).backgroundColor,
//                       backgroundColor: Theme.of(context).disabledColor,
//                       playedColor: Theme.of(context).colorScheme.primaryVariant,
//                       handleColor: Theme.of(context).colorScheme.primaryVariant,
//                     ))));
//   }

//   // Widget _buildSpeedButton() {
//   //   return GestureDetector(
//   //     onTap: () async {
//   //       _hideTimer?.cancel();
//   //
//   //       final chosenSpeed = await showModalBottomSheet<double>(
//   //         context: context,
//   //         isScrollControlled: true,
//   //         useRootNavigator: true,
//   //         builder: (context) => PlaybackSpeedDialog(
//   //           speeds: chewieController.playbackSpeeds,
//   //           selected: _latestValue.playbackSpeed,
//   //         ),
//   //       );
//   //
//   //       if (chosenSpeed != null) {
//   //         controller.setPlaybackSpeed(chosenSpeed);
//   //       }
//   //
//   //       if (_latestValue.isPlaying) {
//   //         _startHideTimer();
//   //       }
//   //     },
//   //     child: AnimatedOpacity(
//   //       opacity: _hideStuff ? 0.0 : 1.0,
//   //       duration: const Duration(milliseconds: 300),
//   //       child: ClipRect(
//   //         child: Container(
//   //           height: barHeight,
//   //           alignment: const Alignment(0.0, -0.1),
//   //           padding: const EdgeInsets.only(right: 4.0),
//   //           child: const Icon(Icons.speed, size: 20, color: Colors.white),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
// }
