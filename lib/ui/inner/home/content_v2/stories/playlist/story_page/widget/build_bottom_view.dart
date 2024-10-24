import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/loading_music_story.dart';
import 'package:provider/provider.dart';
// import 'package:story_view/story_view.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/widget/build_viewer_stories_button.dart';
import '../../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../../constant/widget/music_status_page_widget.dart';

class BuildBottomView extends StatefulWidget {
  // final StoryController? storyController;
  final AnimationController? animationController;
  final ContentData? data;
  final int? currentStory;
  final int currentIndex;
  final Function()? pause;
  final Function()? play;
  final Function(bool)? selectedText;
  // final VoidCallback(bool? bool)? onTap;


  BuildBottomView({
    Key? key,
    // this.storyController,
    this.animationController,
    required this.data,
    required this.currentStory,
    required this.currentIndex,
    this.pause,
    this.play,
    this.selectedText,
  });

  @override
  State<BuildBottomView> createState() => _BuildBottomViewState();
}

class _BuildBottomViewState extends State<BuildBottomView> with AfterFirstLayoutMixin {

  FocusNode _focus = FocusNode();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BuildBottomView');
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void deactivate() {
    final notifier = context.read<StoriesPlaylistNotifier>();
    notifier.setIsPreventedEmoji(true);
    super.deactivate();
  }

  void _onFocusChange() {
    // widget.onTap
    widget.selectedText!(_focus.hasFocus);
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
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
                  Builder(builder: (context) {
                    final lang = context.read<TranslateNotifierV2>().translate;
                    return Container(
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
                                  focusNode: _focus,
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
                                    hintText: "${lang.replyTo} ${widget.data?.username}...",
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
                                  onTap: () async {
                                    widget.pause!();
                                    await context.handleActionIsGuest(() async  {
                                      print("sentuh dong");
                                      widget.pause!();
                                      widget.animationController!.reset();
                                      widget.animationController!.stop();

                                      notifier.forceStop = true;
                                    }, addAction: (){
                                      _focus.unfocus();
                                    });
                                    widget.play!();
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
                                  animationController: widget.animationController,
                                  data: widget.data,
                                  pause: widget.pause,
                                  play: widget.play,
                                  selectedText: widget.selectedText,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
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
