import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/screen_v2.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/arguments/contents/story_detail_screen_argument.dart';
import '../../../../../../constant/widget/custom_loading.dart';
import '../notifier.dart';

class StoryGroupScreen extends StatefulWidget {
  final StoryDetailScreenArgument argument;

  const StoryGroupScreen({Key? key, required this.argument}) : super(key: key);

  @override
  State<StoryGroupScreen> createState() => _StoryGroupScreenState();
}

class _StoryGroupScreenState extends State<StoryGroupScreen> with AfterFirstLayoutMixin {
  late PageController _pageController;
  final notifier = StoriesPlaylistNotifier();

  @override
  void initState() {
    super.initState();
    print('initState peopleIndex : ${widget.argument.peopleIndex}');
    _pageController = PageController(initialPage: widget.argument.peopleIndex);
    _pageController.addListener(() => notifier.initialCurrentPage(_pageController.page));
    notifier.initStateGroup(context, widget.argument);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notif = context.read<StoriesPlaylistNotifier>();
    notif.currentIndex = -1;
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.removeListener(() => this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoriesPlaylistNotifier>(
      create: (context) => notifier,
      child: WillPopScope(
        onWillPop: () async {
          notifier.onCloseStory(mounted);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Consumer<StoriesPlaylistNotifier>(
            builder: (context, notifier, child) {
              print('groupUserStories : ${notifier.groupUserStories}');
              return notifier.groupUserStories.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: notifier.groupUserStories.length,
                      onPageChanged: (index) async {

                        print('StoryGroupScreen index: $index');
                        notifier.currentIndex = index;
                      },
                      itemBuilder: (context, index) {
                        final key = notifier.groupUserStories.keys.elementAt(index);
                        print('Story index $index : ${notifier.currentPage}, ${notifier.currentIndex}, $key');
                        final values = notifier.groupUserStories[key] ?? [];
                        if (notifier.currentIndex == index && notifier.currentPage?.floor() == index) {
                          double value = (notifier.currentPage ?? 1) - index;
                          double degValue = notifier.degreeToRadian(value * 90);
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(degValue),
                            alignment: Alignment.centerRight,
                            child: StoryPageV2(
                              isScrolling: _pageController.position.activity?.isScrolling ?? false,
                              controller: _pageController,
                              index: index,
                              stories: values,
                            ),
                          );
                        }

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
                      })
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
            },
          ),
        ),
      ),
    );
  }
}
