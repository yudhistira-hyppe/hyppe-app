import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/stories/notifier.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';

// import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';

class PeopleFrameStory extends StatelessWidget {
  final int index;
  final StoriesGroup? data;

  const PeopleFrameStory({
    Key? key,
    required this.index,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PeopleFrameStory');
    final getData = data?.story?[0];
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.5),
          child: StoryColorValidator(
            // haveStory: data[index].story.map((e) => e.isView).contains(0),
            haveStory: index.isEven,
            contentData: getData,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: CustomProfileImage(
                following: true,
                width: SizeWidget.circleDiameterOutside,
                height: SizeWidget.circleDiameterOutside,
                onTap: () {
                  context.read<PreviewStoriesNotifier>().changeBorderColor(getData ?? ContentData());
                  context.read<ViewerStoriesNotifier>().postViewer(context, getData?.postID ?? '');
                  // if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
                  // context.read<PreviewStoriesNotifier>().navigateToShortVideoPlayer(context, index);
                  context.read<PreviewStoriesNotifier>().navigateToPeopleStoryGroup(context, index);
                },
                // imageUrl: context.read<PreviewStoriesNotifier>().onProfilePicShow(data[index].profilePicture),
                imageUrl: System().showUserPicture(getData?.avatar?.mediaEndpoint),
                forStory: true,
              ),
            ),
          ),
        ),
        fourPx,
        SizedBox(
          width: 38,
          child: CustomTextWidget(
            maxLines: 1,
            textAlign: TextAlign.center,
            // textToDisplay: data[index].username,
            textToDisplay: '${data?.username}',
            textStyle: _themes.textTheme.overline,
          ),
        ),
      ],
    );
  }
}
