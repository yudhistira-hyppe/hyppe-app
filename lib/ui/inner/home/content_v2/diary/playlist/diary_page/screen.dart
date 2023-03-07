import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/music_status_page_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/content_violation.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/diary_sensitive.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:story_view/story_view.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/left_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/title_playlist_diaries.dart';

import '../../../../../../../app.dart';
import '../../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../../core/services/shared_preference.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../constant/entities/like/notifier.dart';

class DiaryPage extends StatefulWidget {
  final ContentData? data;
  final bool? isScrolling;
  final Function function;
  final PageController? controller;
  final int? total;

  DiaryPage({this.data, this.isScrolling, required this.function, this.controller, this.total});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  // bool _postViewAdded = false;
  List<StoryItem> _storyItems = [];
  final StoryController _storyController = StoryController();
  // int _curentPosition = 0;
  bool isLoading = false;

  // void _addPostView() {
  //   if (widget.data.postView == PostView.notViewed) {
  //     if (!_postViewAdded) {
  //       context.read<DiariesPlaylistNotifier>().addPostViewMixin(context, widget.data).then((value) => _postViewAdded = value);
  //     }
  //   }
  // }

  @override
  void initState() {
    isLoading = true;
    final notifier = Provider.of<DiariesPlaylistNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        notifier.initializeData(context, _storyController, widget.data ?? ContentData());
        _storyItems = notifier.result;
        isLoading = false;
        if (widget.data?.certified ?? false) {
          print('pindah screen2 ${widget.data?.certified ?? false}');
          System().block(context);
        } else {
          System().disposeBlock();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    '_storyController dispose'.logger();
    if (!_storyController.playbackNotifier.isClosed) {
      _storyController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _forcePause = context.select((DiariesPlaylistNotifier value) => value.forcePause);
    final notifier = Provider.of<DiariesPlaylistNotifier>(context);
    // logic when list isScrolled, pause the story
    if (widget.isScrolling ?? false) {
      _storyController.pause();
    } else if (_storyController.playbackNotifier.valueOrNull == PlaybackState.pause) {
      _storyController.play();
    }

    if (_forcePause) _storyController.pause();

    if (_storyItems.isNotEmpty) {
      return isLoading
          ? Container(
              color: Colors.black,
              width: 100,
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 60,
                    child: SizedBox(
                      height: 10,
                      child: CustomLoading(),
                    ),
                  ),
                ],
              ))
          : Stack(
              children: [
                widget.data?.reportedStatus == "BLURRED"
                    ? Container()
                    : StoryView(
                        inline: false,
                        repeat: true,
                        progressColor: kHyppeLightButtonText,
                        durationColor: kHyppeLightButtonText,
                        storyItems: _storyItems,
                        onDouble: () {
                          context.read<LikeNotifier>().likePost(context, widget.data ?? ContentData());
                        },
                        controller: _storyController,
                        progressPosition: ProgressPosition.top,
                        onStoryShow: (storyItem) {
                          int pos = _storyItems.indexOf(storyItem);

                          context.read<DiariesPlaylistNotifier>().setCurrentDiary(pos);
                          // _addPostView();
                          _storyController.playbackNotifier.listen((value) {
                            if (value == PlaybackState.previous) {
                              if (widget.controller?.page == 0) {
                                // context.read<DiariesPlaylistNotifier>().onWillPop(true);
                              } else {
                                widget.controller?.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                              }
                            }
                          });
                        },
                        onInit: () {
                          context.incrementAdsCount();
                        },
                        nextDebouncer: false,
                        onComplete: () async {
                          await notifier.initAdsData(context);
                          widget.controller?.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);

                          // _storyController.next();
                          // widget.controller.

                          // final isLastPage = widget.total - 1 == widget.controller.page;
                          // widget.function();
                          // if (isLastPage) {
                          //   context.read<DiariesPlaylistNotifier>().onWillPop(mounted);
                          // }
                        },
                        onEverySecond: (duration) async {
                          // final secondAds = secondOfAds(notifier.adsData);
                          // print(' ZT secondAds : $secondAds');
                          // print(' ZT secondVid : ${duration}');
                          // print(' ZT URL : ${notifier.adsUrl}');

                          if (duration == secondOfAds(notifier.adsData)) {
                            if (notifier.adsUrl.isNotEmpty) {
                              final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);

                              if (!isShowAds) {
                                _storyController.pause();
                                if (globalAudioPlayer != null) {
                                  globalAudioPlayer!.pause();
                                }
                                await System().adsPopUp(context, notifier.adsData, notifier.adsUrl, isSponsored: notifier.isSponsored, isPopUp: false);
                                if (globalAudioPlayer != null) {
                                  globalAudioPlayer!.resume();
                                }
                                _storyController.play();
                              }
                            }
                          }
                        },
                        onVerticalSwipeComplete: (v) {
                          if (v == Direction.down) context.read<DiariesPlaylistNotifier>().onWillPop(mounted);
                        },
                      ),
                widget.data?.reportedStatus == "BLURRED"
                    ? CustomBackgroundLayer(
                        sigmaX: 30,
                        sigmaY: 30,
                        // thumbnail: picData!.content[arguments].contentUrl,
                        thumbnail: (widget.data?.isApsara ?? false) ? widget.data?.mediaThumbEndPoint ?? '' : widget.data?.fullThumbPath ?? '',
                      )
                    : Container(),
                (widget.data?.reportedStatus == "BLURRED") ? DiarySensitive(data: widget.data) : Container(),
                TitlePlaylistDiaries(
                  data: widget.data,
                  storyController: _storyController,
                ),
                widget.data?.reportedStatus == "BLURRED"
                    ? Container()
                    : RightItems(
                        data: widget.data ?? ContentData(),
                      ),
                widget.data?.reportedStatus == "BLURRED"
                    ? Container()
                    : LeftItems(
                        description: widget.data?.description,
                        // tags: widget.data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" "),
                        music: widget.data?.music,
                        authorName: widget.data?.username,
                        userName: widget.data?.username,
                        location: widget.data?.location,
                        postID: widget.data?.postID,
                        storyController: _storyController,
                        tagPeople: widget.data?.tagPeople,
                        data: widget.data,
                      ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: widget.data?.email == SharedPreference().readStorage(SpKeys.email) && (widget.data?.reportedStatus == 'OWNED')
                      ? SizedBox(height: 58, child: ContentViolationWidget(data: widget.data!))
                      : Container(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: widget.data?.reportedStatus == "BLURRED"
                      ? Container()
                      : widget.data?.music?.musicTitle != null
                          ? Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: MusicStatusPage(
                                music: widget.data!.music!,
                                isPlay: false,
                              ),
                            )
                          : Container(),
                )
              ],
            );
    } else {
      Future.delayed(Duration(seconds: 2), () {
        return isLoading
            ? Container(
                color: Colors.black,
                width: 100,
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 60,
                      child: SizedBox(
                        height: 10,
                        child: CustomLoading(),
                      ),
                    ),
                  ],
                ))
            : Center(
                child: GestureDetector(
                  // onTap: () => context.read<DiariesPlaylistNotifier>().onWillPop(context, widget.arguments),
                  onTap: () => context.read<DiariesPlaylistNotifier>().onWillPop(mounted),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CustomTextWidget(
                      maxLines: 1,
                      textToDisplay: notifier.language.noData ?? '',
                      textStyle: Theme.of(context).textTheme.button,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              );
      });

      return Container(
          color: Colors.black,
          width: 100,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                height: 60,
                child: SizedBox(
                  height: 10,
                  child: CustomLoading(),
                ),
              ),
            ],
          ));
    }
  }

  int secondOfAds(AdsData data) {
    var result = 2;
    final mid = widget.data?.metadata?.midRoll ?? 2;
    final duration = widget.data?.metadata?.duration ?? 2;
    switch (data.adsPlace) {
      case 'First':
        result = ((widget.data?.metadata?.preRoll ?? 0) == 0)
            ? 2
            : (widget.data?.metadata?.preRoll ?? 1) == 1
                ? (widget.data?.metadata?.preRoll ?? 1) + 1
                : (widget.data?.metadata?.preRoll ?? 1);
        break;
      case 'Mid':
        result = mid != 0 ? mid : (duration / 2).toInt();
        break;
      case 'End':
        result = (widget.data?.metadata?.postRoll ?? 2) != 0 ? widget.data?.metadata?.postRoll ?? 1 : duration - 1;
        break;
      default:
        result = 2;
        break;
    }
    return result;
  }
}
