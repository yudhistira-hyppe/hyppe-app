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

import '../../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../../constant/widget/music_status_page_widget.dart';

class BuildBottomView extends StatefulWidget {
  final StoryController storyController;
  final AnimationController? animationController;
  final ContentData? data;
  final int? currentStory;

  BuildBottomView({
    Key? key,
    required this.storyController,
    required this.animationController,
    required this.data,
    required this.currentStory,
  });

  @override
  State<BuildBottomView> createState() => _BuildBottomViewState();
}

class _BuildBottomViewState extends State<BuildBottomView> {

  @override
  void initState() {
    super.initState();
    final notifier = context.read<StoriesPlaylistNotifier>();
    notifier.isLoadMusic = true;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);

    return notifier.isUserLoggedIn(widget.data?.email)
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewerStoriesButton(
          data: widget.data,
          currentStory: widget.currentStory,
          storyController: widget.storyController,
        ),

      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
          children: [
            if(widget.data?.music?.apsaraMusic != null)
              notifier.isLoadMusic ? LoadingMusicStory(apsaraMusic: widget.data!.music!.apsaraMusic!): MusicStatusPage(music: widget.data!.music!, urlMusic: notifier.urlMusic,),
            if(widget.data?.music?.apsaraMusic != null)
              eightPx,
            AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: MediaQuery.of(context).viewInsets.bottom,
      height: SizeWidget().calculateSize(83, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
      child: Container(
            alignment: Alignment.center,
            width: SizeConfig.screenWidth,
            height: SizeWidget().calculateSize(83, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: SizeWidget().calculateSize(!notifier.isKeyboardActive ? 274 : 290, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()),
                  margin: const EdgeInsets.only(left: 10),
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
                    onTap: () => notifier.forceStop = true,
                    onChanged: (value) => notifier.onChangeHandler(context, value),
                    onFieldSubmitted: (value) => notifier.textEditingController.text = value,
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: BuildButton(
                      storyController: widget.storyController,
                      animationController: widget.animationController,
                      data: widget.data,
                    ),
                  ),
                )
              ],
            ),
      ),
    ),
          ],
        );
  }
}


