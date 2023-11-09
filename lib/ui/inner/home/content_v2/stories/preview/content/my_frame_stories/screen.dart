import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MyFrameStory');
    SizeConfig().init(context);
    final notifier = Provider.of<PreviewStoriesNotifier>(context);
    context.select((ErrorService value) => value.getError(ErrorType.peopleStory));
    final home = context.watch<HomeNotifier>();
    final email = SharedPreference().readStorage(SpKeys.email);
    return Row(
      children: [
        sixteenPx,
        // Text("${notifier.isloading}"),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            !notifier.isloading
                ? BuildCircleProfile(
                    listStory: notifier.myStoryGroup[email],
                    imageUrlKey: home.profileImageKey,
                    imageUrl: System().showUserPicture(home.profileImage),
                    badge: notifier.myStoryGroup.isEmpty ? home.profileBadge : notifier.myStoryGroup[email]?[0].urluserBadge,
                  )
                : const CustomShimmer(
                    radius: 50,
                    width: SizeWidget.circleDiameterOutside,
                    height: SizeWidget.circleDiameterOutside,
                  ),
            fourPx,
            !notifier.isloading
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
