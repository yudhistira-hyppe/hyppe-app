import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
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

import '../../../../../notifier_v2.dart';

class MyFrameStory extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final notifier = Provider.of<PreviewStoriesNotifier>(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.peopleStory));
    final home = Provider.of<HomeNotifier>(context);
    final email = SharedPreference().readStorage(SpKeys.email);
    return Row(
      children: [
        sixteenPx,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            context.read<ErrorService>().isInitialError(error, notifier.myStoryGroup) || notifier.myStoryGroup != null
                ? BuildCircleProfile(
                    listStory: notifier.myStoryGroup[email],
                    imageUrl: System().showUserPicture(home.profileImage),
                  )
                : const CustomShimmer(
                    radius: 50,
                    width: SizeWidget.circleDiameterOutside,
                    height: SizeWidget.circleDiameterOutside,
                  ),
            fourPx,
            context.read<ErrorService>().isInitialError(error, notifier.myStoryGroup) || notifier.myStoryGroup != null
                ? SizedBox(
                    width: 43,
                    child: CustomTextWidget(
                      maxLines: 1,
                      textToDisplay: context.read<TranslateNotifierV2>().translate.yourStory ?? '',
                      textStyle: Theme.of(context).textTheme.overline?.copyWith(letterSpacing: notifier.myStoryGroup.isEmpty ? null : 1.0),
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
