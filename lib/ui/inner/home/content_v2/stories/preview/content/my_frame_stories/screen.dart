import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/content/my_frame_stories/widget/build_circle_profile.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:tuple/tuple.dart';

class MyFrameStory extends StatelessWidget {
  static final _system = System();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final myStoriesData = context.select((PreviewStoriesNotifier value) => Tuple2(value.myStoriesData, value.totalViews));
    final myPicture = context.select((SelfProfileNotifier value) => value.user.profile?.avatar?.mediaEndpoint);
    final error = context.select((ErrorService value) => value.getError(ErrorType.peopleStory));

    return Row(
      children: [
        sixteenPx,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            context.read<ErrorService>().isInitialError(error, myStoriesData.item1) || myStoriesData.item1 != null
                ? BuildCircleProfile(
                    listStory: myStoriesData.item1 ?? [],
                    imageUrl: System().showUserPicture(myPicture),
                  )
                : const CustomShimmer(
                    radius: 50,
                    width: SizeWidget.circleDiameterOutside,
                    height: SizeWidget.circleDiameterOutside,
                  ),
            fourPx,
            context.read<ErrorService>().isInitialError(error, myStoriesData.item1) || myStoriesData.item1 != null
                ? SizedBox(
                    width: 43,
                    child: CustomTextWidget(
                      maxLines: 1,
                      textToDisplay: myStoriesData.item1?.isEmpty ?? [].isEmpty
                          ? context.read<TranslateNotifierV2>().translate.yourStory!
                          : "${_system.formatterNumber(myStoriesData.item2)} / ${_system.formatterNumber(myStoriesData.item1?.length)}",
                      textStyle: Theme.of(context).textTheme.overline!.copyWith(letterSpacing: myStoriesData.item1?.isEmpty ?? [].isEmpty ? null : 1.0),
                    ),
                  )
                : const CustomShimmer(
                    height: 6,
                    width: 43,
                    radius: 50,
                  ),
          ],
        ),
        fourPointFivePx
      ],
    );
  }
}
