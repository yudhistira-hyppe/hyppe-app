import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_background_layer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/link_copied_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_dynamic_link_error.dart';
import 'package:story_view/story_view.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_bottom_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_replay_caption.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_top_view.dart';

import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../constant/entities/like/notifier.dart';

class StoryPage extends StatefulWidget {
  final ContentData? data;
  final int? storyParentIndex;
  final bool? isScrolling;
  final Function? onNextPage;
  final PageController? controller;
  final int index;

  const StoryPage({
    this.onNextPage,
    this.data,
    this.isScrolling,
    this.storyParentIndex,
    this.controller,
    required this.index
  });
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin, AfterFirstLayoutMixin {
  String _when = "";
  List<StoryItem> _storyItems = [];
  AnimationController? _animationController;
  final StoryController _storyController = StoryController();
  bool isLoading = false;

  @override
  void initState() {
    if (widget.data != null) {
      _when = '${System().readTimestamp(
        DateTime.parse(widget.data?.createdAt ?? '').millisecondsSinceEpoch,
        context,
        fullCaption: true,
      )}';
    }
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _storyController.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);
    if (MediaQuery.of(context).viewInsets.bottom > 0.0 || notifier.textEditingController.text.isNotEmpty) {
      setState(() => notifier.setIsKeyboardActive(true));
    } else {
      setState(() => notifier.setIsKeyboardActive(false));
    }
    // logic when list isScrolled, pause the story
    if (widget.isScrolling ?? false) {
      _storyController.pause();
    } else {
      if (_storyController.playbackNotifier.valueOrNull == PlaybackState.pause && !notifier.isKeyboardActive && !notifier.isShareAction && !notifier.isReactAction) {
        _storyController.play();
      }
      // if (_storyController.playbackNotifier.valueOrNull == PlaybackState.pause && !notifier.isKeyboardActive && !notifier.isShareAction) {
      //   _storyController.play();
      // }
    }

    if (notifier.forceStop) {
      _storyController.pause();
    }

    // if (widget.userID != null) {
    //   if (_storyItems.isEmpty) {
    //     _storyItems = notifier.initializeData(context, _storyController, widget.data);
    //   }
    // }
    print('_storyItems : ${_storyItems.length}, $isLoading');
    if (_storyItems.isEmpty) {
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
                      height: 90,
                      child: SizedBox(
                        height: 10,
                        child: CustomLoading(),
                      ),
                    ),
                  ],
                ))
            : Center(
                child: GestureDetector(
                  onTap: () => notifier.onCloseStory(mounted),
                  child: const CustomDynamicLinkErrorWidget(),
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
                height: 90,
                child: SizedBox(
                  height: 10,
                  child: CustomLoading(),
                ),
              ),
            ],
          ));
    } else {
      return isLoading
          ? Container(
              color: Colors.black,
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          height: 90,
                          child: SizedBox(
                            height: 10,
                            child: CustomLoading(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomTextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.only(left: 0.0),
                          ),
                        ),
                        // onPressed: () => notifier.onCloseStory(context, arguments),
                        onPressed: () => notifier.onCloseStory(mounted),
                        child: const CustomIconWidget(
                          defaultColor: false,
                          color: kHyppeLightButtonText,
                          iconData: "${AssetPath.vectorPath}close.svg",
                        ),
                      ),
                    ),
                  )
                ],
              ))
          : Stack(
              children: [
                widget.data?.isReport ?? false
                    ? Container()
                    : StoryView(
                        inline: false,
                        repeat: false,
                        progressColor: kHyppeLightButtonText,
                        durationColor: kHyppeLightButtonText,
                        onDouble: () {
                          print('testtttt');
                          context.read<LikeNotifier>().likePost(context, widget.data ?? ContentData());
                        },
                        controller: _storyController,
                        storyItems: _storyItems,
                        progressPosition: ProgressPosition.top,
                        onStoryShow: (storyItem) async {
                          int pos = _storyItems.indexOf(storyItem);
                          notifier.setCurrentStory(pos);
                          if (pos > 0) {
                            // notifier.when = System().readTimestamp(int.parse(widget.data.story[pos].timestamp), fullCaption: true);
                            // setState(() => _when = System().readTimestamp(int.parse(widget.data.story[pos].timestamp), context, fullCaption: true));
                            setState(() {
                              _when = '${System().readTimestamp(
                                DateTime.parse(System().dateTimeRemoveT(widget.data?.createdAt ?? '')).millisecondsSinceEpoch,
                                context,
                                fullCaption: true,
                              )}';
                            });
                          }

                          _storyController.playbackNotifier.listen((value) {
                            if (value == PlaybackState.previous) {
                              if (widget.controller?.page == 0) {
                                notifier.onCloseStory(mounted);
                              } else {
                                widget.controller?.previousPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                              }
                            }
                          });

                          // if (widget.userID == null) await notifier.addStoryView(context, pos, widget.data, widget.storyParentIndex, widget.userID);
                        },
                        onComplete: () {
                          widget.controller?.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                          final currentIndex = notifier.dataUserStories.length - 1;
                          final isLastPage = currentIndex == widget.controller?.page;
                          // _pageController.nextPage(duration: const Duration(seconds: 1), curve: Curves.easeInOut);
                          // notifier.pageController =
                          print('onComplete Diary');
                          System().increaseViewCount(context, widget.data ?? ContentData()).whenComplete(() {});
                          Timer(const Duration(seconds: 1), () {
                            // widget.onNextPage();
                            // notifier.onCloseStory(mounted);
                            // notifier.nextPage();
                            // _storyController.next();
                          });
                          if (isLastPage) {
                            notifier.onCloseStory(mounted);
                          }
                        },
                        onEverySecond: (duration) {},
                        onVerticalSwipeComplete: (v) {
                          // if (v == Direction.down && mounted) notifier.onCloseStory(context, widget.arguments);
                          if (v == Direction.down) notifier.onCloseStory(mounted);
                        },
                      ),
                // Padding(
                //   padding: const EdgeInsets.all(200.0),
                //   child: Text("${widget.data.isApsara}"),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(top: 200.0),
                //   child: SelectableText("${widget.data.fullThumbPath}"),
                // ),
                widget.data?.isReport ?? false
                    ? Stack(
                        children: [
                          CustomBackgroundLayer(
                            sigmaX: 30,
                            sigmaY: 30,
                            // thumbnail: picData!.content[arguments].contentUrl,
                            thumbnail: (widget.data?.isApsara ?? false) ? widget.data?.mediaThumbEndPoint : widget.data?.fullThumbPath,
                          ),
                          SafeArea(
                              child: SizedBox(
                            width: SizeConfig.screenWidth,
                            child: Consumer<TranslateNotifierV2>(
                              builder: (context, transnot, child) => Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Spacer(),
                                  const CustomIconWidget(
                                    iconData: "${AssetPath.vectorPath}eye-off.svg",
                                    defaultColor: false,
                                    height: 30,
                                  ),
                                  Text(transnot.translate.sensitiveContent ?? 'Sensitive Content', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  Text("HyppeStory ${transnot.translate.contentContainsSensitiveMaterial}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      )),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<ReportNotifier>().seeContent(context, widget.data!, hyppeStory);
                                      context.read<StoriesPlaylistNotifier>().onUpdate();
                                    },
                                    child: Container(
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
                                        "${transnot.translate.see} HyppeStory",
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  thirtyTwoPx,
                                ],
                              ),
                            ),
                          )),
                        ],
                      )
                    : Container(),
                BuildTopView(
                  when: _when,
                  data: widget.data,
                  storyController: _storyController,
                ),
                widget.data?.isReport ?? false
                    ? Container()
                    : Form(
                        child: BuildBottomView(
                          data: widget.data,
                          storyController: _storyController,
                          currentStory: notifier.currentStory,
                          animationController: _animationController,
                          currentIndex: widget.index,
                        ),
                      ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  transitionBuilder: (child, animation) {
                    animation = CurvedAnimation(parent: animation, curve: Curves.bounceOut);

                    return ScaleTransition(
                      scale: animation,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: notifier.linkCopied
                      ? const Center(
                          child: LinkCopied(),
                        )
                      : const SizedBox.shrink(),
                ),
                BuildReplayCaption(data: widget.data),
                ...notifier.buildItems(_animationController!)
              ],
            );
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    isLoading = true;
    final notifier = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration.zero, () {
        notifier.initializeData(context, _storyController, widget.data ?? ContentData());
        setState(() {
          _storyItems = notifier.result;
          isLoading = false;
        });
      });
    });
  }
}
