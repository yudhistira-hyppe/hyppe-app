import 'dart:async';
import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:story_view/handlers/video_event_handler.dart';
import 'package:story_view/services/event_service.dart';
// import 'package:story_view/widget/story_error.dart';
// import 'package:story_view/widget/story_loading.dart';
// import 'package:video_player/video_player.dart';
// import 'package:better_player/better_player.dart';

import '../controller/story_controller.dart';
import '../utils.dart';
import 'story_image.dart';
import 'story_video.dart';

/// Indicates where the progress indicators should be placed.
enum ProgressPosition { top, bottom }

/// This is used to specify the height of the progress indicator. Inline stories
/// should use [small]
enum IndicatorHeight { small, large }

/// This is a representation of a story item (or page).
class StoryItem {
  /// Specifies how long the page should be displayed. It should be a reasonable
  /// amount of time greater than 0 milliseconds.
  final Duration duration;

  /// Has this page been shown already? This is used to indicate that the page
  /// has been displayed. If some pages are supposed to be skipped in a story,
  /// mark them as shown `shown = true`.
  ///
  /// However, during initialization of the story view, all pages after the
  /// last unshown page will have their `shown` attribute altered to false. This
  /// is because the next item to be displayed is taken by the last unshown
  /// story item.
  bool shown;

  String? source;

  bool? isImages;

  /// The page content
  final Widget view;
  StoryItem(
    this.view, {
    this.source,
    this.shown = false,
    this.isImages = false,
    required this.duration,
  });

  /// Short hand to create text-only page.
  ///
  /// [title] is the text to be displayed on [backgroundColor]. The text color
  /// alternates between [Colors.black] and [Colors.white] depending on the
  /// calculated contrast. This is to ensure readability of text.
  ///
  /// Works for inline and full-page stories. See [StoryView.inline] for more on
  /// what inline/full-page means.
  static StoryItem text({
    required String title,
    required Color backgroundColor,
    Key? key,
    TextStyle? textStyle,
    bool shown = false,
    bool roundedTop = false,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    double contrast = ContrastHelper.contrast([
      backgroundColor.red,
      backgroundColor.green,
      backgroundColor.blue,
    ], [
      255,
      255,
      255
    ] /** white text */);

    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(roundedTop ? 8 : 0),
            bottom: Radius.circular(roundedBottom ? 8 : 0),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        child: Center(
          child: Text(
            title,
            style: textStyle?.copyWith(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                ) ??
                TextStyle(
                  color: contrast > 1.8 ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        //color: backgroundColor,
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Factory constructor for page images. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageImage({
    required String url,
    required StoryController controller,
    Key? key,
    Color? backgroundColor,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    bool isImages = true,
    Map<String, String>? requestHeaders,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            StoryImage.url(
              url,
              backgroundColor: backgroundColor,
              controller: controller,
              fit: imageFit,
              requestHeaders: requestHeaders,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  color: caption != null ? Colors.black54 : Colors.transparent,
                  child: caption != null
                      ? Text(
                          caption,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox(),
                ),
              ),
            )
          ],
        ),
      ),
      shown: shown,
      isImages: true,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating inline image. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.inlineImage({
    required String url,
    required Text caption,
    required StoryController controller,
    Key? key,
    BoxFit imageFit = BoxFit.cover,
    Map<String, String>? requestHeaders,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      ClipRRect(
        key: key,
        child: Container(
          color: Colors.grey[100],
          child: Container(
            color: Colors.black,
            child: Stack(
              children: <Widget>[
                StoryImage.url(
                  url,
                  controller: controller,
                  fit: imageFit,
                  requestHeaders: requestHeaders,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      child: caption,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(roundedTop ? 8 : 0),
          bottom: Radius.circular(roundedBottom ? 8 : 0),
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  /// Shorthand for creating page video. [controller] should be same instance as
  /// one passed to the `StoryView`
  factory StoryItem.pageVideo(
    String url, {
    required StoryController controller,
    Key? key,
    Duration? duration,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Map<String, String>? requestHeaders,

    /// Xulu Developer Code:
    Color? backgroundColor,
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              StoryVideo.url(
                url,
                controller: controller,
                requestHeaders: requestHeaders,

                /// Xulu Developer Code:
                backgroundColor: backgroundColor,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        source: url,
        shown: shown,
        duration: duration ?? const Duration(seconds: 1));
  }

  /// Shorthand for creating a story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.pageProviderImage(
    ImageProvider image, {
    Key? key,
    BoxFit imageFit = BoxFit.fitWidth,
    String? caption,
    bool shown = false,
    Duration? duration,
  }) {
    return StoryItem(
        Container(
          key: key,
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Center(
                child: Image(
                  image: image,
                  height: double.infinity,
                  width: double.infinity,
                  fit: imageFit,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 24,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    color: caption != null ? Colors.black54 : Colors.transparent,
                    child: caption != null
                        ? Text(
                            caption,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox(),
                  ),
                ),
              )
            ],
          ),
        ),
        shown: shown,
        duration: duration ?? const Duration(seconds: 3));
  }

  /// Shorthand for creating an inline story item from an image provider such as `AssetImage`
  /// or `NetworkImage`. However, the story continues to play while the image loads
  /// up.
  factory StoryItem.inlineProviderImage(
    ImageProvider image, {
    Key? key,
    Text? caption,
    bool shown = false,
    bool roundedTop = true,
    bool roundedBottom = false,
    Duration? duration,
  }) {
    return StoryItem(
      Container(
        key: key,
        decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(roundedTop ? 8 : 0),
              bottom: Radius.circular(roundedBottom ? 8 : 0),
            ),
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
            )),
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              child: caption ?? const SizedBox(),
              width: double.infinity,
            ),
          ),
        ),
      ),
      shown: shown,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}

/// Widget to display stories just like Whatsapp and Instagram. Can also be used
/// inline/inside [ListView] or [Column] just like Google News app. Comes with
/// gestures to pause, forward and go to previous page.
class StoryView extends StatefulWidget {
  /// The pages to displayed.
  final List<StoryItem?> storyItems;

  /// Callback for when a full cycle of story is shown. This will be called
  /// each time the full story completes when [repeat] is set to `true`.
  final VoidCallback? onComplete;

  final VoidCallback? onRepeat;

  final VoidCallback? onInit;

  final Function(int)? onEverySecond;

  /// Callback for when a vertical swipe gesture is detected. If you do not
  /// want to listen to such event, do not provide it. For instance,
  /// for inline stories inside ListViews, it is preferrable to not to
  /// provide this callback so as to enable scroll events on the list view.
  final Function(Direction?)? onVerticalSwipeComplete;

  /// Callback for when a story is currently being shown.
  final ValueChanged<StoryItem>? onStoryShow;

  /// Where the progress indicator should be placed.
  final ProgressPosition progressPosition;

  /// Should the story be repeated forever?
  final bool repeat;

  final bool isAds;

  /// If you would like to display the story as full-page, then set this to
  /// `false`. But in case you would display this as part of a page (eg. in
  /// a [ListView] or [Column]) then set this to `true`.
  final bool inline;

  ///Callback when you double click the view story
  final Function? onDouble;

  // Controls the playback of the stories
  final StoryController controller;

  final Color progressColor;
  final Color durationColor;
  final bool? nextDebouncer;

  StoryView({
    Key? key,
    required this.storyItems,
    required this.controller,
    required this.progressColor,
    required this.durationColor,
    this.onDouble,
    this.onComplete,
    this.onRepeat,
    this.onInit,
    this.onStoryShow,
    this.onEverySecond,
    this.progressPosition = ProgressPosition.top,
    this.isAds = false,
    this.repeat = false,
    this.inline = false,
    this.onVerticalSwipeComplete,
    this.nextDebouncer = true,
  })  : assert(storyItems.isNotEmpty, "[storyItems] should not be empty"),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoryViewState();
  }
}

class StoryViewState extends State<StoryView> with TickerProviderStateMixin, VideoEventHandler {
  final EventService _eventService = EventService();

  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  Timer? _nextDebouncer;
  // int? _fileVideoDuration;
  // bool? _isInit = false;
  // BetterPlayerController? _videoPlayerController;

  StreamSubscription<PlaybackState>? _playbackSubscription;
  VerticalDragInfo? verticalDragInfo;
  bool statusPlay = false;
  bool statusPlayOnPress = false;

  // Duration? durationAds = Duration();
  int durationAds = 0;
  Timer? timerAds;

  // StoryItem? get _currentStory => widget.storyItems.firstWhere((it) => !it!.shown, orElse: () => null);
  StoryItem? get _currentStory => widget.storyItems.firstWhereOrNull((it) => !it!.shown);

  // Widget get _currentView => widget.storyItems.firstWhere((it) => !it!.shown, orElse: () => widget.storyItems.last)!.view;
  // Widget? get _currentView => widget.storyItems.firstWhereOrNull((it) => !it!.shown)?.view;
  Widget get _currentView {
    try {
      return widget.storyItems.firstWhere((it) => !it!.shown)!.view;
    } catch (stateError) {
      return widget.storyItems.last!.view;
    }
  }

  void reset() {
    setState(() => durationAds = 0);
  }

  void playTimer() {
    timerAds = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerAds?.isActive ?? false) {
        print('status periodic $durationAds');
      }

      setState(() {
        if (timerAds?.isActive ?? false) {
          final seconds = durationAds + 1;
          if (seconds > (_currentStory?.duration.inSeconds ?? 15)) {
            durationAds = 0;
          } else {
            durationAds = seconds;
            if (widget.onEverySecond != null) {
              widget.onEverySecond!(durationAds);
            }
          }
          timerAds = timer;
        }
      });
    });
  }

  void pauseTimer({bool isReset = false}) {
    if (isReset) {
      reset();
    }
    setState(() {
      timerAds?.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    _eventService.addVideoHandler(kVideoEventKey, this);

    // All pages after the first unshown page should have their shown value as
    // false

    /// Original
    // final firstPage = widget.storyItems.firstWhere((it) {
    //   return !it!.shown;
    // }, orElse: () {
    //   widget.storyItems.forEach((it2) {
    //     it2!.shown = false;
    //   });
    //
    //   return null;
    // });

    /// My
    // final firstPage = widget.storyItems.firstWhereOrNull((it) {
    //   return !it!.shown;
    // });

    StoryItem? firstPage;

    try {
      firstPage = widget.storyItems.firstWhere((it) => !it!.shown);
    } catch (stateError) {
      for (var it2 in widget.storyItems) {
        it2!.shown = false;
      }
      firstPage = null;
    }

    if (firstPage != null) {
      final lastShownPos = widget.storyItems.indexOf(firstPage);
      widget.storyItems.sublist(lastShownPos).forEach((it) {
        it!.shown = false;
      });
    }

    _playbackSubscription = widget.controller.playbackNotifier.listen((playbackStatus) {
      print('playbackStatus : ${playbackStatus}');
      switch (playbackStatus) {
        case PlaybackState.play:
          final isRunning = timerAds == null ? false : timerAds!.isActive;
          if (isRunning) {
            pauseTimer();
            // _animationController?.forward();
          } else {
            playTimer();
            _animationController?.forward();
            // _animationController?.stop(canceled: false);
          }
          _removeNextHold();
          print('curent story hahahahahah');
          print(_currentStory?.isImages);
          if (_currentStory!.isImages!) _animationController?.forward();

          // print(_currentStory?.shown);
          // print(_currentStory?.view);
          statusPlay = true;
          break;

        case PlaybackState.pause:
          print('pause_2');
          pauseTimer();
          _holdNext(); // then pause animation
          _animationController?.stop(canceled: false);
          statusPlay = false;
          break;

        case PlaybackState.next:
          _removeNextHold();

          _goForward();
          break;

        case PlaybackState.previous:
          _removeNextHold();

          _goBack();
          break;
        case PlaybackState.replay:
          break;
      }
    });

    _play();
  }

  @override
  void dispose() {
    if (widget.isAds) {
      print('pause_3');
      pauseTimer(isReset: true);
    } else {
      pauseTimer();
    }

    _clearDebouncer();

    _animationController?.dispose();
    _playbackSubscription?.cancel();

    _eventService.removeVideoHandler(kVideoEventKey);

    super.dispose();
  }

  @override
  void setState(fn) {
    try {
      if (mounted) {
        super.setState(fn);
      }
    } catch (e) {
      print('error amount $e');
    }
  }

  @override
  void onBetterPlayerEventChange(event) {
    print('betterPlayerEventType : ${event.betterPlayerEventType}');

    if (event.betterPlayerEventType == BetterPlayerEventType.bufferingStart) {
      // pauseTimer();
      _animationController?.stop(canceled: false);
      setState(() {});
    } else if (event.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
      _animationController?.forward();
      setState(() {});
    } else if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (widget.onInit != null) {
        widget.onInit!();
      }
    } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
      _animationController?.forward();
      setState(() {});
    } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
      _animationController?.stop(canceled: false);
      setState(() {});
    }
  }

  void _play() async {
    _animationController?.dispose();
    // get the next playing page
    final storyItem = widget.storyItems.firstWhere((it) {
      return !it!.shown;
    })!;

    if (widget.onStoryShow != null) {
      widget.onStoryShow!(storyItem);
    }

    // init duration when file is video
    // if (storyItem.isVideoFile != null) await _loadVideoFileDuration(storyItem.source!);

    //   if (_isInit != null) {
    //     _animationController = AnimationController(
    //         duration: storyItem.isVideoFile != null && _fileVideoDuration != null
    //             ? Duration(milliseconds: _fileVideoDuration!)
    //             : storyItem.duration,
    //         vsync: this);

    //     _animationController!.addStatusListener((status) {
    //       if (status == AnimationStatus.completed) {
    //         storyItem.shown = true;
    //         if (widget.storyItems.last != storyItem) {
    //           _beginPlay();
    //         } else {
    //           // done playing
    //           _onComplete();
    //         }
    //       }
    //     });

    //     _currentAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    //     widget.controller.play();
    //   }
    // }

    _animationController = AnimationController(
      vsync: this,
      // duration: storyItem.isVideoFile != null && _fileVideoDuration != null ? Duration(milliseconds: _fileVideoDuration!) : storyItem.duration,
      duration: storyItem.duration,
    );

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        storyItem.shown = true;

        if (widget.storyItems.last != storyItem) {
          _beginPlay();
        } else {
          // done playing
          if(widget.repeat){
            widget.controller.replay();
          }
          _onComplete();
        }
      }
    });
    _currentAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);
    widget.controller.play();
  }

  void _beginPlay() {
    setState(() {});
    _play();
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.controller.pause();
      widget.onComplete!();
      print('pause_1');
      pauseTimer(isReset: true);
    }

    if (widget.repeat) {
      for (var it in widget.storyItems) {
        it!.shown = false;
      }
      if (widget.onRepeat != null) {
        widget.onRepeat!();
      }
      _beginPlay();
    }
  }

  void _goBack() {
    _animationController!.stop();

    if (_currentStory == null) {
      widget.storyItems.last!.shown = false;
    }

    if (_currentStory == widget.storyItems.first) {
      _beginPlay();
    } else {
      _currentStory!.shown = false;
      int lastPos = widget.storyItems.indexOf(_currentStory);
      final previous = widget.storyItems[lastPos - 1]!;

      previous.shown = false;

      _beginPlay();
    }
  }

  void _goForward() {
    if (_currentStory != widget.storyItems.last) {
      _animationController!.stop();

      // get last showing
      final _last = _currentStory;

      if (_last != null) {
        _last.shown = true;
        if (_last != widget.storyItems.last) {
          _beginPlay();
        }
      }
    } else {
      // this is the last page, progress animation should skip to end
      _animationController!.animateTo(1.0, duration: const Duration(milliseconds: 10));
    }
  }

  void _clearDebouncer() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _removeNextHold() {
    _nextDebouncer?.cancel();
    _nextDebouncer = null;
  }

  void _holdNext() {
    _nextDebouncer?.cancel();
    _nextDebouncer = Timer(const Duration(milliseconds: 500), () {});
  }

  @override
  Widget build(BuildContext context) {
    // if (_isInit == null) {
    //   return Center(
    //     child: StoryError(),
    //   );
    // }

    // if (_isInit!) {
    //   return Center(
    //     child: StoryLoading(),
    //   );
    // }

    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          _currentView,
          Align(
            alignment: widget.progressPosition == ProgressPosition.top ? Alignment.topCenter : Alignment.bottomCenter,
            child: SafeArea(
              bottom: widget.inline ? false : true,
              // we use SafeArea here for notched and bezeles phones
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: PageBar(
                  widget.storyItems.map((it) => PageData(it!.duration, it.shown)).toList(),
                  _currentAnimation,
                  key: UniqueKey(),
                  progressColor: widget.progressColor,
                  durationColor: widget.durationColor,
                  indicatorHeight: widget.inline ? IndicatorHeight.small : IndicatorHeight.large,
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              heightFactor: 1,
              child: GestureDetector(
                // onTapDown: (details) {
                //   print('onTapDown');
                //   widget.controller.pause();
                // },
                onTapCancel: () {
                  print('onTapCancel');
                  widget.controller.play();
                },
                onDoubleTap: () {
                  if (widget.onDouble != null) {
                    widget.onDouble!();
                  }
                },
                onTap: () {
                  if (widget.nextDebouncer == true) {
                    widget.controller.next();
                  } else {
                    if (statusPlay) {
                      print('pause');
                      widget.controller.pause();
                    } else {
                      print('play');
                      widget.controller.play();
                    }
                  }
                },
                onLongPress: () {
                  widget.controller.pause();
                },
                onLongPressEnd: (de) {
                  print('play1');
                  widget.controller.play();
                },
                // onTapDown: (details) {
                //   Future.delayed(const Duration(seconds: 2), () {
                //     // deleayed code here
                //     statusPlayOnPress = true;
                //     widget.controller.pause();
                //   });
                // },
                // onTapUp: (details) {
                //   if (statusPlayOnPress) {
                //     statusPlayOnPress = false;
                //     widget.controller.play();
                //   }
                // },
                // onTapUp: (details) {
                //   print('onTapUp');
                //   // if debounce timed out (not active) then continue anim
                //   if (_nextDebouncer?.isActive == true && widget.nextDebouncer == true) {
                //     widget.controller.next();
                //   } else {
                //     if (widget.controller.playbackNotifier.isPaused) {
                //       widget.controller.pause();
                //     } else {
                //       widget.controller.play();
                //     }
                //     print(widget.controller.playbackNotifier.isPaused);
                //     // widget.controller.playbackNotifier.listen((playbackStatus) {
                //     //   switch (playbackStatus) {
                //     //     case PlaybackState.play:
                //     //       widget.controller.pause();
                //     //       break;

                //     //     case PlaybackState.pause:
                //     //       widget.controller.play();
                //     //       break;
                //     //     case PlaybackState.next:
                //     //       // TODO: Handle this case.
                //     //       break;
                //     //     case PlaybackState.previous:
                //     //       // TODO: Handle this case.
                //     //       break;
                //     //   }
                //     // });
                //   }
                // },
                onVerticalDragStart: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        print("pause1");
                        widget.controller.pause();
                      },
                onVerticalDragCancel: widget.onVerticalSwipeComplete == null
                    ? null
                    : () {
                        print('play2');
                        if (statusPlay) widget.controller.play();
                      },
                onVerticalDragUpdate: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        verticalDragInfo ??= VerticalDragInfo();

                        verticalDragInfo!.update(details.primaryDelta!);

                        // TODO: provide callback interface for animation purposes
                      },
                onVerticalDragEnd: widget.onVerticalSwipeComplete == null
                    ? null
                    : (details) {
                        print('play3');
                        widget.controller.play();
                        // finish up drag cycle
                        if (!verticalDragInfo!.cancel && widget.onVerticalSwipeComplete != null) {
                          widget.onVerticalSwipeComplete!(verticalDragInfo!.direction);
                        }

                        verticalDragInfo = null;
                      },
              )),
          Align(
            alignment: Alignment.centerLeft,
            heightFactor: 1,
            child: SizedBox(
                child: GestureDetector(onTap: () {
                  if (widget.nextDebouncer == true) widget.controller.previous();
                }),
                width: 70),
          ),
        ],
      ),
    );
  }
}

/// Capsule holding the duration and shown property of each story. Passed down
/// to the pages bar to render the page indicators.
class PageData {
  Duration duration;
  bool shown;

  PageData(this.duration, this.shown);
}

/// Horizontal bar displaying a row of [StoryProgressIndicator] based on the
/// [pages] provided.
class PageBar extends StatefulWidget {
  final List<PageData> pages;
  final Animation<double>? animation;
  final IndicatorHeight indicatorHeight;

  final Color progressColor;
  final Color durationColor;

  const PageBar(
    this.pages,
    this.animation, {
    required this.progressColor,
    required this.durationColor,
    this.indicatorHeight = IndicatorHeight.large,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PageBarState();
  }
}

class PageBarState extends State<PageBar> {
  double spacing = 4;

  @override
  void initState() {
    super.initState();

    int count = widget.pages.length;
    spacing = (count > 15) ? 1 : ((count > 10) ? 2 : 4);

    widget.animation!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isPlaying(PageData page) {
    return widget.pages.firstWhereOrNull((it) => !it.shown) == page;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.pages.map((it) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.only(right: widget.pages.last == it ? 0 : spacing),
            child: StoryProgressIndicator(
              isPlaying(it) ? widget.animation!.value : (it.shown ? 1 : 0),
              indicatorHeight: widget.indicatorHeight == IndicatorHeight.large ? 5 : 3,
              durationColor: widget.durationColor,
              progressColor: widget.progressColor,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Custom progress bar. Supposed to be lighter than the
/// original [ProgressIndicator], and rounded at the sides.
class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;
  final Color progressColor;
  final Color durationColor;

  const StoryProgressIndicator(
    this.value, {
    required this.progressColor,
    required this.durationColor,
    this.indicatorHeight = 5,
  }) : assert(indicatorHeight > 0, "[indicatorHeight] should not be less than 1");

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(
        indicatorHeight,
      ),
      foregroundPainter: IndicatorOval(
        progressColor.withOpacity(0.8),
        value,
      ),
      painter: IndicatorOval(
        durationColor.withOpacity(0.4),
        1.0,
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;

  IndicatorOval(this.color, this.widthFactor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width * widthFactor, size.height), const Radius.circular(3)), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Concept source: https://stackoverflow.com/a/9733420
class ContrastHelper {
  static double luminance(int? r, int? g, int? b) {
    final a = [r, g, b].map((it) {
      double value = it!.toDouble() / 255.0;
      return value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4);
    }).toList();

    return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722;
  }

  static double contrast(rgb1, rgb2) {
    return luminance(rgb2[0], rgb2[1], rgb2[2]) / luminance(rgb1[0], rgb1[1], rgb1[2]);
  }
}
