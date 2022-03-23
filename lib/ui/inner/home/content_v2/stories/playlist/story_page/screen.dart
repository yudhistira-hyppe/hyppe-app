import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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

class StoryPage extends StatefulWidget {
  final ContentData? data;
  final int? storyParentIndex;
  final bool? isScrolling;
  final Function? onNextPage;

  const StoryPage({
    this.onNextPage,
    this.data,
    this.isScrolling,
    this.storyParentIndex,
  });
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  String _when = "";
  List<StoryItem> _storyItems = [];
  AnimationController? _animationController;
  final StoryController _storyController = StoryController();

  @override
  void initState() {
    final notifier = Provider.of<StoriesPlaylistNotifier>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _storyItems = notifier.initializeData(context, _storyController, widget.data!);
    });
    if (widget.data != null) {
      _when = '${System().readTimestamp(
        DateTime.parse(widget.data!.createdAt!).millisecondsSinceEpoch,
        context,
        fullCaption: true,
      )}';
    }
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    super.initState();
  }

  @override
  void dispose() {
    _storyController.dispose();
    _animationController?.dispose();
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
    if (widget.isScrolling!) {
      _storyController.pause();
    } else {
      if (_storyController.playbackNotifier.valueOrNull == PlaybackState.pause &&
          !notifier.isKeyboardActive &&
          !notifier.isShareAction &&
          !notifier.isReactAction) {
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
    //     _storyItems = notifier.initializeData(context, _storyController, widget.data!);
    //   }
    // }

    if (_storyItems.isEmpty) {
      return Center(
        child: GestureDetector(
          onTap: () => notifier.onCloseStory(mounted),
          child: const CustomDynamicLinkErrorWidget(),
        ),
      );
    }

    return Stack(
      children: [
        StoryView(
          inline: false,
          repeat: false,
          progressColor: kHyppeLightButtonText,
          durationColor: kHyppeLightButtonText,
          controller: _storyController,
          storyItems: _storyItems,
          progressPosition: ProgressPosition.top,
          onStoryShow: (storyItem) async {
            int pos = _storyItems.indexOf(storyItem);
            notifier.setCurrentStory(pos);
            if (pos > 0) {
              // notifier.when = System().readTimestamp(int.parse(widget.data!.story[pos].timestamp!), fullCaption: true);
              // setState(() => _when = System().readTimestamp(int.parse(widget.data!.story[pos].timestamp!), context, fullCaption: true));
              setState(() {
                _when = '${System().readTimestamp(
                  DateTime.parse(widget.data!.createdAt!).millisecondsSinceEpoch,
                  context,
                  fullCaption: true,
                )}';
              });
            }
            // if (widget.userID == null) await notifier.addStoryView(context, pos, widget.data!, widget.storyParentIndex!, widget.userID);
          },
          onComplete: () {
            Timer(const Duration(seconds: 1), () {
              notifier.onCloseStory(mounted);
              System().increaseViewCount(context, widget.data!).whenComplete(() {
                setState(() {});
              });
            });
          },
          onVerticalSwipeComplete: (v) {
            // if (v == Direction.down && mounted) notifier.onCloseStory(context, widget.arguments);
            if (v == Direction.down) notifier.onCloseStory(mounted);
          },
        ),
        BuildTopView(
          when: _when,
          data: widget.data,
          storyController: _storyController,
        ),
        Form(
          child: BuildBottomView(
            data: widget.data,
            storyController: _storyController,
            currentStory: notifier.currentStory,
            animationController: _animationController,
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
        ...notifier.buildItems(_animationController)
      ],
    );
  }
}
