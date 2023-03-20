import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/loading_music_story.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_viewer_stories_button.dart';
import '../../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../../constant/widget/music_status_page_widget.dart';

class BuildBottomView extends StatefulWidget {
  final StoryController? storyController;
  final AnimationController? animationController;
  final ContentData? data;
  final int? currentStory;
  final int currentIndex;
  final Function? pause;

  BuildBottomView({
    Key? key,
    this.storyController,
    this.animationController,
    required this.data,
    required this.currentStory,
    required this.currentIndex,
    this.pause,
  });

  @override
  State<BuildBottomView> createState() => _BuildBottomViewState();
}

class _BuildBottomViewState extends State<BuildBottomView> with AfterFirstLayoutMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);

    return notifier.isUserLoggedIn(widget.data?.email)
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ViewerStoriesButton(
                  data: widget.data,
                  pause: widget.pause,
                  currentStory: widget.currentStory == -1 ? 0 : widget.currentStory,
                  storyController: widget.storyController,
                ),
                if (widget.data?.music?.musicTitle != null)
                  Container(
                      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: MusicStatusPage(
                        music: widget.data!.music!,
                      )),
              ],
            ),
          )
        : AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: MediaQuery.of(context).viewInsets.bottom,
            height: SizeWidget().calculateSize(150, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
            child: Container(
              alignment: Alignment.center,
              width: SizeConfig.screenWidth,
              height: SizeWidget().calculateSize(150, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: SizeConfig.screenWidth,
                    height: SizeWidget().calculateSize(40, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    child: widget.data?.music?.musicTitle != null
                        ? widget.data?.mediaType == 'video'
                            ? MusicStatusPage(
                                music: widget.data!.music!,
                                vertical: 0,
                              )
                            : notifier.isLoadMusic
                                ? LoadingMusicStory(
                                    apsaraMusic: widget.data!.music!,
                                    index: widget.currentIndex,
                                    current: widget.currentStory ?? 0,
                                  )
                                : MusicStatusPage(
                                    music: widget.data!.music!,
                                    urlMusic: notifier.urlMusic?.playUrl ?? '',
                                    vertical: 0,
                                  )
                        : const SizedBox.shrink(),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: SizeConfig.screenWidth,
                    height: SizeWidget().calculateSize(65, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: SizeWidget().calculateSize(!notifier.isKeyboardActive ? 274 : 290, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()),
                          margin: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () {
                              widget.pause!();
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: TextFormField(
                                maxLines: null,
                                validator: (String? input) {
                                  if (input?.isEmpty ?? true) {
                                    return "Please enter message";
                                  } else {
                                    return null;
                                  }
                                },
                                controller: notifier.textEditingController,
                                keyboardAppearance: Brightness.dark,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: "Balas ke ${widget.data?.username}...",
                                  fillColor: Theme.of(context).colorScheme.background,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
                                  ),
                                ),
                                onTap: () {
                                  print("sentuh dong");
                                  widget.pause!();
                                  widget.pause!();
                                  widget.animationController!.stop();

                                  notifier.forceStop = true;
                                },
                                onChanged: (value) => notifier.onChangeHandler(context, value),
                                onFieldSubmitted: (value) => notifier.textEditingController.text = value,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: BuildButton(
                                storyController: widget.storyController,
                                animationController: widget.animationController,
                                data: widget.data,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<StoriesPlaylistNotifier>();
    notifier.isLoadMusic = true;
  }
}
