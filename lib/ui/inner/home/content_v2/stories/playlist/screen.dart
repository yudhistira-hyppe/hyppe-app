
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/screen.dart';

import 'package:hyppe/core/arguments/contents/story_detail_screen_argument.dart';

import '../preview/notifier.dart';

class HyppePlaylistStories extends StatefulWidget {
  final StoryDetailScreenArgument argument;

  const HyppePlaylistStories({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  HyppePlaylistStoriesState createState() => HyppePlaylistStoriesState();
}

class HyppePlaylistStoriesState extends State<HyppePlaylistStories> with AfterFirstLayoutMixin {
  late PageController _pageController;
  final notifier = StoriesPlaylistNotifier();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.argument.index.toInt());
    _pageController.addListener(() => notifier.initialCurrentPage(_pageController.page));
    notifier.initState(context, widget.argument);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    notifier.currentIndex = -1;

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
            builder: (context, value, child) {
              return notifier.dataUserStories.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: notifier.dataUserStories.length,
                      onPageChanged: (index) async{
                        notifier.currentIndex = index;
                        if(notifier.dataUserStories.length > 5){
                          if(index == (notifier.dataUserStories.length - 1)){
                            final values = await notifier.myContentsQuery.loadNext(context, isLandingPage: true);
                            if(values.isNotEmpty){
                              notifier.dataUserStories = [...(notifier.dataUserStories)] + values;
                            }

                            final prev = context.read<PreviewStoriesNotifier>();
                            prev.initialPeopleStories(context, list: values);
                          }
                        }
                      },
                      itemBuilder: (context, index) {
                        if (notifier.currentPage?.floor() == index) {
                          double value = (notifier.currentPage ?? 1) - index;
                          double degValue = notifier.degreeToRadian(value * 90);
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(degValue),
                            alignment: Alignment.centerRight,
                            child: StoryPage(
                              isScrolling: _pageController.position.activity?.isScrolling,
                              storyParentIndex: notifier.storyParentIndex,
                              data: notifier.dataUserStories[index],
                              onNextPage: () => notifier.nextPage(),
                              index: index,
                              controller: _pageController,
                            ),
                          );
                        } else if ((notifier.currentPage?.floor() ?? 0) + 1 == index) {
                          double value = (notifier.currentPage ?? 1) - index;
                          double degValue = notifier.degreeToRadian(value * 90);
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(degValue),
                            alignment: Alignment.centerLeft,
                            child: StoryPage(
                              isScrolling: _pageController.position.activity?.isScrolling,
                              storyParentIndex: notifier.storyParentIndex,
                              data: notifier.dataUserStories[index],
                              index: index,
                              onNextPage: () => notifier.nextPage(),
                              controller: _pageController,
                            ),
                          );
                        }
                        return StoryPage(
                          isScrolling: _pageController.position.activity?.isScrolling,
                          storyParentIndex: notifier.storyParentIndex,
                          data: notifier.dataUserStories[index],
                          index: index,
                          onNextPage: () => notifier.nextPage(),
                          controller: _pageController,
                        );
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        backgroundColor: Theme.of(context).colorScheme.primaryVariant,
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
