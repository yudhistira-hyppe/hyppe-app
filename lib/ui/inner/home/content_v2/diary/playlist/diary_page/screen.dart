import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_tag_label.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:story_view/story_view.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/left_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/right_items.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/playlist/widget/title_playlist_diaries.dart';

class DiaryPage extends StatefulWidget {
  final ContentData? data;
  final bool? isScrolling;
  final Function function;

  const DiaryPage({
    this.data,
    this.isScrolling,
    required this.function,
  });
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  // bool _postViewAdded = false;
  List<StoryItem> _storyItems = [];
  final StoryController _storyController = StoryController();

  // void _addPostView() {
  //   if (widget.data!.postView == PostView.notViewed) {
  //     if (!_postViewAdded) {
  //       context.read<DiariesPlaylistNotifier>().addPostViewMixin(context, widget.data!).then((value) => _postViewAdded = value);
  //     }
  //   }
  // }

  @override
  void initState() {
    final notifier = Provider.of<DiariesPlaylistNotifier>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _storyItems = notifier.initializeData(context, _storyController, widget.data!);
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
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _forcePause = context.select((DiariesPlaylistNotifier value) => value.forcePause);

    // logic when list isScrolled, pause the story
    if (widget.isScrolling!) {
      _storyController.pause();
    } else if (_storyController.playbackNotifier.valueOrNull == PlaybackState.pause) {
      _storyController.play();
    }

    if (_forcePause) _storyController.pause();

    if (_storyItems.isNotEmpty) {
      return Stack(
        children: [
          StoryView(
            inline: false,
            repeat: false,
            progressColor: kHyppeLightButtonText,
            durationColor: kHyppeLightButtonText,
            storyItems: _storyItems,
            controller: _storyController,
            progressPosition: ProgressPosition.top,
            onStoryShow: (storyItem) {
              int pos = _storyItems.indexOf(storyItem);
              context.read<DiariesPlaylistNotifier>().setCurrentDiary(pos);
              // _addPostView();
              print('Current position $pos');
            },
            onComplete: () => widget.function(),
          ),
          TitlePlaylistDiaries(
            data: widget.data,
            storyController: _storyController,
          ),
          RightItems(
            data: widget.data!,
          ),
          Align(
            alignment: const Alignment(1.0, 0.70),
            child: widget.data?.tagPeople!.length != 0 || widget.data?.location == ''
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 26, top: 16),
                    child: Row(
                      children: [
                        widget.data?.tagPeople!.length != 0
                            ? PicTagLabel(
                                icon: 'user',
                                label: '${widget.data?.tagPeople!.length} people',
                                function: () {
                                  _storyController.pause();
                                  context.read<PicDetailNotifier>().showUserTag(context, widget.data!.tagPeople, widget.data?.postID, storyController: _storyController);
                                },
                              )
                            : const SizedBox(),
                        widget.data?.location == '' || widget.data?.location == null
                            ? const SizedBox()
                            : PicTagLabel(
                                icon: 'maptag',
                                label: "${widget.data?.location}",
                                function: () {},
                              ),
                      ],
                    ),
                  )
                : const SizedBox(),
          ),
          LeftItems(
            description: widget.data?.description,
            tags: widget.data?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" "),
            musicName: "Dangdut koplo remix",
            authorName: widget.data?.username,
            userName: widget.data?.username,
          ),
        ],
      );
    }

    return Center(
      child: GestureDetector(
        // onTap: () => context.read<DiariesPlaylistNotifier>().onWillPop(context, widget.arguments),
        onTap: () => context.read<DiariesPlaylistNotifier>().onWillPop(mounted),
        child: Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          child: CustomTextWidget(
            maxLines: 1,
            textToDisplay: context.watch<TranslateNotifierV2>().translate.noData!,
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
  }
}
