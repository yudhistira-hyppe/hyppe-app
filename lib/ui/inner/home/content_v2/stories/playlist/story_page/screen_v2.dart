import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_bottom_view.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_replay_caption.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_top_view.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/size_config.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../constant/entities/like/notifier.dart';
import '../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_loading.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../../../../../../constant/widget/link_copied_widget.dart';
import '../notifier.dart';

class StoryPageV2 extends StatefulWidget {
  final List<ContentData> stories;
  bool? isScrolling;
  final PageController? controller;

  StoryPageV2({
    Key? key,
    required this.stories,
    this.isScrolling,
    this.controller,
  }) : super(key: key);

  @override
  State<StoryPageV2> createState() => _StoryPageV2State();
}

class _StoryPageV2State extends State<StoryPageV2> with SingleTickerProviderStateMixin, AfterFirstLayoutMixin {
  Map<String, String> times = {};
  late AnimationController animationController;
  final StoryController _storyController = StoryController();
  late ContentData currentData;
  bool isLoading = false;

  @override
  void initState() {
    isLoading = true;
    currentData = widget.stories[0];
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    if (widget.stories.isNotEmpty) {
      for (final story in widget.stories) {
        final postId = story.postID;
        if (postId != null) {
          times[postId] = '${System().readTimestamp(
            DateTime.parse(story.createdAt ?? '').millisecondsSinceEpoch,
            context,
            fullCaption: true,
          )}';
        }
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _storyController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // final notifier = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final notifier = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
      notifier.initializeUserStories(context, _storyController, widget.stories);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isLoading = false;
        });
      });
    });
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
    }

    if (notifier.forceStop) {
      _storyController.pause();
    }

    if (notifier.result.isEmpty) {
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
          : Container(
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
                        onPressed: () => notifier.onCloseStory(context, mounted),
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
                StoryView(
                  inline: false,
                  repeat: false,
                  progressColor: kHyppeLightButtonText,
                  durationColor: kHyppeLightButtonText,
                  onDouble: () {
                    print('testtttt');
                    context.read<LikeNotifier>().likePost(context, currentData);
                  },
                  controller: _storyController,
                  storyItems: notifier.result,
                  progressPosition: ProgressPosition.top,
                  onStoryShow: (storyItem) async {
                    setState(() {
                      int pos = notifier.result.indexOf(storyItem);
                      notifier.setCurrentStory(pos);
                      try {
                        currentData = widget.stories.where((element) => element.postID == storyItem.id).first;
                      } catch (e) {
                        'Error get current content data: $e'.logger();
                      }
                    });

                    _storyController.playbackNotifier.listen((value) {
                      if (value == PlaybackState.previous) {
                        print("widget.controller?.page ${storyItem}");
                        if (notifier.currentStory == 0) {
                          print('kesini');
                          // notifier.onCloseStory(context, mounted);
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
                    System().increaseViewCount(context, currentData).whenComplete(() {});
                    if (isLastPage) {
                      notifier.onCloseStory(context, mounted);
                    }
                  },
                  onEverySecond: (duration) {},
                  onVerticalSwipeComplete: (v) {
                    // if (v == Direction.down && mounted) notifier.onCloseStory(context, widget.arguments);
                    if (v == Direction.down) notifier.onCloseStory(context, mounted);
                  },
                ),
                Container(),
                BuildTopView(
                  when: times[currentData.postID ?? ''] ?? '',
                  data: currentData,
                  storyController: _storyController,
                ),
                Form(
                  child: BuildBottomView(
                    data: currentData,
                    storyController: _storyController,
                    currentStory: notifier.currentStory,
                    animationController: animationController,
                    currentIndex: widget.stories.indexOf(currentData),
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
                BuildReplayCaption(data: currentData),
                ...notifier.buildItems(animationController)
              ],
            );
    }
  }
}
