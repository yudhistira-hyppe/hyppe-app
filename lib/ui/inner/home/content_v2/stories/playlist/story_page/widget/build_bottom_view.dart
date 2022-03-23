import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_view/story_view.dart';

import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_viewer_stories_button.dart';

class BuildBottomView extends StatelessWidget {
  final StoryController storyController;
  final AnimationController? animationController;
  final ContentData? data;
  final int? currentStory;
  
  const BuildBottomView({
    Key? key,
    required this.storyController,
    required this.animationController,
    required this.data,
    required this.currentStory,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);
    
    return notifier.isUserLoggedIn(data?.email)
        ? ViewerStoriesButton(
            data: data,
            currentStory: currentStory,
          )
        : AnimatedPositioned(
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
                    width: SizeWidget().calculateSize(!notifier.isKeyboardActive ? 274 : 290, SizeWidget.baseWidthXD, SizeConfig.screenWidth!),
                    margin: const EdgeInsets.only(left: 10),
                    child: TextFormField(
                      maxLines: null,
                      validator: (String? input) {
                        if (input!.isEmpty) {
                          return "Please enter message";
                        } else {
                          return null;
                        }
                      },
                      controller: notifier.textEditingController,
                      keyboardAppearance: Brightness.dark,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Balas ke ${data!.username}...",
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
                        storyController: storyController,
                        animationController: animationController,
                        data: data,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
