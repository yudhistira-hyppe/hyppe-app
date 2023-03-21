import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    FirebaseCrashlytics.instance.setCustomKey('layout', 'StoryGroupScreen');
    super.initState();
    _pageController = PageController(initialPage: widget.argument.peopleIndex);
    _pageController.addListener(() => notifier.initialCurrentPage(_pageController.page));
    notifier.initStateGroup(context, widget.argument);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // final notif = context.read<StoriesPlaylistNotifier>();
    // notif.currentIndex = -1;
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
          body: notifier.groupUserStories.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: notifier.groupUserStories.length,
                  onPageChanged: (index) {
                    print('StoryGroupScreen index: $index');
                    notifier.currentIndex = index;
                  },
                  itemBuilder: (context, index) {
                    final fixNotifier = Provider.of<StoriesPlaylistNotifier>(context);
                    // var key = fixNotifier.groupUserStories.keys.elementAt(index);

                    print('Story index $index : ${fixNotifier.currentPage}, ${fixNotifier.currentIndex}, $index');
                    var values = fixNotifier.groupUserStories[index].story ?? [];

                    if (fixNotifier.currentIndex == index && fixNotifier.currentPage == index) {
                      double value = (fixNotifier.currentPage ?? 1) - index;
                      double degValue = fixNotifier.degreeToRadian(value * 90);
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
                      ),
                    );
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
                  ),
                ),
        ),
      ),
    );
  }
}
