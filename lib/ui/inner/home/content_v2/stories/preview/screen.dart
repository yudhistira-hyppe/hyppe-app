import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/content/my_frame_stories/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/content/people_frame_story/screen.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/error_service.dart';

class HyppePreviewStories extends StatefulWidget {
  const HyppePreviewStories({Key? key}) : super(key: key);

  @override
  State<HyppePreviewStories> createState() => _HyppePreviewStoriesState();
}

class _HyppePreviewStoriesState extends State<HyppePreviewStories> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewStories');
    final notifier = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    // notifier.initialStories(context);
    notifier.scrollController.addListener(() {
      if (mounted) {
        notifier.scrollListener(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PreviewStoriesNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.peopleStory));

    return SizedBox(
      width: SizeConfig.screenWidth,
      height: SizeWidget.barStoriesCircleHome,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollStartNotification) {
            Future.delayed(const Duration(milliseconds: 100), () {
              print('hariyanto1');
              // notifier.initialPeopleStories(context);
            });
          }
          return true;
        },
        child: ListView.builder(
          controller: notifier.scrollController,
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(left: 4.5, right: 16.0),
          itemCount: notifier.peopleItemCount(error),
          itemBuilder: (context, index) {
            print('ini story orang ${notifier.storiesGroups?.length}');
            int itemIndex = index - 1;
            if (notifier.storiesGroups != null) {
              if (index == 0) {
                return MyFrameStory();
              }

              if (itemIndex == notifier.storiesGroups?.length && notifier.hasNext) {
                return const CustomLoading(size: 3);
              }

              return PeopleFrameStory(
                index: itemIndex,
                data: notifier.storiesGroups?[itemIndex],
              );
            } else {
              if (context.read<ErrorService>().isInitialError(error, notifier.storiesGroups) || (notifier.storiesGroups?.isNotEmpty ?? [].isEmpty)) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyFrameStory(),
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width * 0.75,
                    //   child: const CustomErrorWidget(
                    //     padding: EdgeInsets.only(left: 20, top: 16, bottom: 16),
                    //     errorType: ErrorType.peopleStory,
                    //     isVertical: false,
                    //     iconSize: 40,
                    //     // function: () => notifier.initialPeopleStories(context),
                    //   ),
                    // ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CustomShimmer(
                      width: SizeWidget.circleDiameterOutside,
                      height: SizeWidget.circleDiameterOutside,
                      radius: 100,
                      margin: EdgeInsets.symmetric(horizontal: 4.5),
                    ),
                    fourPx,
                    CustomShimmer(height: 6, width: 43, radius: 50),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}
