import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/story_page/screen_v2.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/arguments/contents/story_detail_screen_argument.dart';
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
    _pageController = PageController(initialPage: widget.argument.index.toInt());
    _pageController.addListener(() => notifier.initialCurrentPage(_pageController.page));
    notifier.initStateGroup(context, widget.argument);

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
        onWillPop: ()async{
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
                      onPageChanged: (index)async{
                        notifier.currentIndex = index;

                      },
                      itemBuilder: (context, index){
                        try{
                          final key = notifier.groupUserStories.keys.elementAt(index);
                          final values = notifier.groupUserStories[key] ?? [];
                          if (notifier.currentPage?.floor() == index) {
                            double value = (notifier.currentPage ?? 1) - index;
                            double degValue = notifier.degreeToRadian(value * 90);
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(degValue),
                              alignment: Alignment.centerRight,
                              child: StoryPageV2(
                                  isScrolling: _pageController.position.activity?.isScrolling,
                                  controller: _pageController,
                                  stories: values
                              ),
                            );
                          }else if((notifier.currentPage?.floor() ?? 0) + 1 == index){
                            double value = (notifier.currentPage ?? 1) - index;
                            double degValue = notifier.degreeToRadian(value * 90);
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateY(degValue),
                              alignment: Alignment.centerLeft,
                              child: StoryPageV2(
                                isScrolling: _pageController.position.activity?.isScrolling ?? false,
                                controller: _pageController,
                                stories: values,
                              ),
                            );
                          }
                          return StoryPageV2(
                            isScrolling: _pageController.position.activity?.isScrolling ?? false,
                            controller: _pageController,
                            stories: values,
                          );
                        }catch(e){
                          return StoryPageV2(
                            isScrolling: _pageController.position.activity?.isScrolling ?? false,
                            controller: _pageController,
                            stories: [],
                          );
                        }

                      }) :  Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  backgroundColor: Theme.of(context).colorScheme.primaryVariant,
                ),
              );
            },
          ),
        ),
    ),);
  }
}
