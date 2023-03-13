import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/music_status_page_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/loading_music_story.dart';
import 'package:provider/provider.dart';

class BuildBottomView2 extends StatefulWidget {
  final int? currentStory;
  final int? currentIndex;
  final ContentData? data;
  const BuildBottomView2({super.key, this.data, this.currentIndex, this.currentStory});

  @override
  State<BuildBottomView2> createState() => _BuildBottomView2State();
}

class _BuildBottomView2State extends State<BuildBottomView2> with AfterFirstLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<StoriesPlaylistNotifier>();
    notifier.isLoadMusic = true;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);
    return AnimatedPositioned(
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
                              index: widget.currentIndex ?? 0,
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
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: SizeWidget().calculateSize(!notifier.isKeyboardActive ? 274 : 290, SizeWidget.baseWidthXD, SizeConfig.screenWidth ?? context.getWidth()),
                    margin: const EdgeInsets.only(left: 10),
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
                        onTap: () => notifier.forceStop = true,
                        onChanged: (value) => notifier.onChangeHandler(context, value),
                        onFieldSubmitted: (value) => notifier.textEditingController.text = value,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
