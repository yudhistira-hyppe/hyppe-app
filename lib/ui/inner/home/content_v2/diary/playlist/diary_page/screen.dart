import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_tag_label.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:story_view/story_view.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/left_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/title_playlist_diaries.dart';

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

  const DiaryPage({this.data, this.isScrolling, required this.function, this.controller, this.total});

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  // bool _postViewAdded = false;
  List<StoryItem> _storyItems = [];
  final StoryController _storyController = StoryController();
  int _curentPosition = 0;
  bool isLoading = false;

  // void _addPostView() {
  //   if (widget.data!.postView == PostView.notViewed) {
  //     if (!_postViewAdded) {
  //       context.read<DiariesPlaylistNotifier>().addPostViewMixin(context, widget.data!).then((value) => _postViewAdded = value);
  //     }
  //   }
  // }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    final notifier = Provider.of<DiariesPlaylistNotifier>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      notifier.initializeData(context, _storyController, widget.data!);
      _storyItems = notifier.result;
      isLoading = false;
    });

    super.initState();
  }

  // @override
  // void afterFirstLayout(BuildContext context) {
  //   final notifier = Provider.of<DiariesPlaylistNotifier>(context, listen: false);
  //   notifier.checkFollowingToUser(context);
  //   notifier.determineUserLogIn(context);
  // }

  @override
  void dispose() {
    print('_storyController dispose');
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
    if (widget.isScrolling!) {
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
                widget.data!.isReport!
                    ? Container()
                    : StoryView(
                        inline: false,
                        repeat: true,
                        progressColor: kHyppeLightButtonText,
                        durationColor: kHyppeLightButtonText,
                        storyItems: _storyItems,
                        onDouble: () {
                          context.read<LikeNotifier>().likePost(context, widget.data!);
                        },
                        controller: _storyController,
                        progressPosition: ProgressPosition.top,
                        onStoryShow: (storyItem) {
                          int pos = _storyItems.indexOf(storyItem);

                          context.read<DiariesPlaylistNotifier>().setCurrentDiary(pos);
                          // _addPostView();
                          _storyController.playbackNotifier.listen((value) {
                            if (value == PlaybackState.previous) {
                              if (widget.controller!.page == 0) {
                                // context.read<DiariesPlaylistNotifier>().onWillPop(true);
                              } else {
                                widget.controller!.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                              }
                            }
                          });
                        },
                        onInit: () {
                          context.incrementAdsCount();
                        },
                        onRepeat: () {
                          context.incrementAdsCount();
                        },
                        nextDebouncer: false,
                        onComplete: () async {
                          await notifier.initAdsData(context);
                          // widget.controller!.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);

                          // _storyController.next();
                          // widget.controller!.

                          // final isLastPage = widget.total! - 1 == widget.controller!.page;
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
                                await System().adsPopUp(context, notifier.adsData, notifier.adsUrl, isSponsored: notifier.isSponsored);
                                _storyController.play();
                              }
                            }
                          }
                        },
                        onVerticalSwipeComplete: (v) {
                          if (v == Direction.down) context.read<DiariesPlaylistNotifier>().onWillPop(mounted);
                        },
                      ),
                widget.data!.isReport!
                    ? CustomBackgroundLayer(
                        sigmaX: 30,
                        sigmaY: 30,
                        // thumbnail: picData!.content[arguments].contentUrl,
                        thumbnail: (widget.data!.isApsara ?? false) ? widget.data!.mediaThumbEndPoint : widget.data!.fullThumbPath,
                      )
                    : Container(),
                widget.data!.isReport!
                    ? SafeArea(
                        child: SizedBox(
                        width: SizeConfig.screenWidth,
                        child: Consumer<TranslateNotifierV2>(
                          builder: (context, transnot, child) => Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Spacer(),
                              const CustomIconWidget(
                                iconData: "${AssetPath.vectorPath}valid-invert.svg",
                                defaultColor: false,
                                height: 30,
                              ),
                              Text(transnot.translate.reportReceived!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text(transnot.translate.yourReportWillbeHandledImmediately!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  )),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.only(top: 8),
                                margin: const EdgeInsets.all(8),
                                width: SizeConfig.screenWidth,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "${transnot.translate.see} HyppeDiary",
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              thirtyTwoPx,
                            ],
                          ),
                        ),
                      ))
                    : Container(),
                TitlePlaylistDiaries(
                  data: widget.data,
                  storyController: _storyController,
                ),
                widget.data!.isReport!
                    ? Container()
                    : RightItems(
                        data: widget.data!,
                      ),
                widget.data!.isReport!
                    ? Container()
                    : LeftItems(
                        description: widget.data?.description,
                        tags: widget.data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" "),
                        musicName: "Dangdut koplo remix",
                        authorName: widget.data?.username,
                        userName: widget.data?.username,
                        location: widget.data?.location,
                        postID: widget.data?.postID,
                        storyController: _storyController,
                        tagPeople: widget.data!.tagPeople,
                      ),
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
                      textToDisplay: Provider.of<TranslateNotifierV2>(context, listen: false).translate.noData!,
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
                ? widget.data!.metadata!.preRoll! + 1
                : widget.data!.metadata!.preRoll!;
        break;
      case 'Mid':
        result = mid != 0 ? mid : (duration / 2).toInt();
        break;
      case 'End':
        result = (widget.data?.metadata?.postRoll ?? 2) != 0 ? widget.data!.metadata!.postRoll! : duration - 1;
        break;
      default:
        result = 2;
        break;
    }
    return result;
  }
}
