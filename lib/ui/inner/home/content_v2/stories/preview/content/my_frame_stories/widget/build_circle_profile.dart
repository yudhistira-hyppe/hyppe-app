import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/common/user_badge_model.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';

class BuildCircleProfile extends StatelessWidget {
  final List? listStory;
  final String? imageUrl;
  final String? imageUrlKey;
  final Map<String, String>? headers;
  final UserBadgeModel? badge;

  const BuildCircleProfile({
    Key? key,
    this.headers,
    this.imageUrl,
    this.listStory,
    this.imageUrlKey,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BuildCircleProfile');
    SizeConfig().init(context);
    return InkWell(
      // onTap: () => context.read<PreviewStoriesNotifier>().onTapHandler(context),
      onTap: () => context.read<PreviewStoriesNotifier>().navigateToMyStoryGroup(context, listStory ?? []),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          StoryColorValidator(
            featureType: FeatureType.story,
            haveStory: listStory?.isNotEmpty ?? false,
            isMy: true,
            borderRadius: 20,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CustomProfileImage(
                cacheKey: imageUrlKey,
                following: true,
                imageUrl: imageUrl,
                badge: badge,
                headers: headers,
                width: SizeWidget.circleDiameterOutside,
                height: SizeWidget.circleDiameterOutside,
                forStory: true,
                allwaysUseBadgePadding: true,
              ),
            ),
          ),
          Visibility(
            visible: (listStory != null && (listStory?.isNotEmpty ?? false)) ? false : true,
            child: const CustomIconWidget(
              defaultColor: false,
              iconData: '${AssetPath.vectorPath}add-story.svg',
            ),
          ),
        ],
      ),
    );
  }
}
