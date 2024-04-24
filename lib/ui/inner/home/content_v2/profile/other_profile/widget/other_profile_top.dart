import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/collection/user_v2/profile/user_profile_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/show_image_profile.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../constant/widget/custom_desc_content_widget.dart';

class OtherProfileTop extends StatelessWidget {
  final String? email;
  final UserProfileModel? profile;
  final Map<String, List<ContentData>>? otherStoryGroup;

  const OtherProfileTop({Key? key, this.email, this.profile, this.otherStoryGroup}) : super(key: key);

  void showTap(BuildContext context, List<ContentData> dataStory, OtherProfileNotifier notifier) {
    if (dataStory.isNotEmpty) {
      context.read<PreviewStoriesNotifier>().navigateToOtherStoryGroup(context, dataStory, email ?? '', isOther: true);
    } else {
      showPict(context, notifier);
    }
  }

  void showPict(BuildContext context, OtherProfileNotifier notifier) {
    final imageUrl = notifier.displayPhotoProfileOriginal();
    // if (notifier.manyUser.first.profile?.avatar?.mediaEndpoint?.isNotEmpty ?? false) {
    showDialog(
      context: context,
      builder: (context) {
        return ShowImageProfile(imageUrl: imageUrl!);
      },
      // barrierColor: Colors.red,
    );
    // }
  }

  String displayBio() => profile != null
      ? profile?.bio != null
          ? '${profile?.bio}'
          : ""
      : "";

  String? displayPlace() {
    String? area = profile?.area;
    String? country = profile?.country;
    if (area != null && country != null) {
      return " $area - $country";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sn = Provider.of<PreviewStoriesNotifier>(context);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfileTop');
    final myEmail = SharedPreference().readStorage(SpKeys.email);
    return Consumer<OtherProfileNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.only(top: 16.0 * SizeConfig.scaleDiagonal, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("${notifier.manyUser.last.pics?.length}"),
            Row(
              children: [
                // StoryColorValidator(
                //   haveStory: notifier.checkHaveStory(context),
                //   featureType: FeatureType.other,
                //   child: CustomProfileImage(
                //     following: true,
                //     width: 80 * SizeConfig.scaleDiagonal,
                //     height: 80 * SizeConfig.scaleDiagonal,
                //     imageUrl: notifier.displayPhotoProfile(),
                //     onTap: () => notifier.viewStory(context),
                //   ),
                // ),
                StoryColorValidator(
                  isMy: false,
                  haveStory: (otherStoryGroup?[email]?.isEmpty ?? [].isEmpty) ? false : true,
                  featureType: (otherStoryGroup?[email]?.isEmpty ?? [].isEmpty) ? FeatureType.other : FeatureType.story,
                  isView: (otherStoryGroup?[email]?.isEmpty ?? [].isEmpty) ? false : (otherStoryGroup?[email]?.last.isViewed ?? false),
                  child: GestureDetector(
                    onTap: () {
                      showTap(context, sn.otherStoryGroup[email] ?? [], notifier);
                    },
                    onLongPress: () {
                      showPict(context, notifier);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CustomProfileImage(
                        following: true,
                        forStory: true,
                        width: 76 * SizeConfig.scaleDiagonal,
                        height: 76 * SizeConfig.scaleDiagonal,
                        imageUrl: System().showUserPicture(profile?.avatar?.mediaEndpoint),
                        badge: profile?.urluserBadge,
                        allwaysUseBadgePadding: true,
                        // imageUrl: notifier.displayPhotoProfile(),
                      ),
                    ),
                  ),
                ),
                fourteenPx,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          children: [
                            CustomTextWidget(
                              // textToDisplay: notifier.displayPostsCount(),
                              textToDisplay: System().formatterNumber((profile?.insight?.posts ?? 0).toInt()),
                              textStyle: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.posts ?? 'Posts',
                              textStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            CustomTextWidget(
                              // textToDisplay: notifier.displayFollowers(),
                              textToDisplay: System().formatterNumber((profile?.insight?.followers ?? 0).toInt()),
                              textStyle: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.followers ?? 'Followers',
                              textStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            CustomTextWidget(
                              // textToDisplay: notifier.displayFollowing(),
                              textToDisplay: System().formatterNumber((profile?.insight?.followings ?? 0).toInt()),
                              textStyle: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.following ?? 'Following',
                              textStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
              child: CustomTextWidget(
                textToDisplay: profile?.fullName ?? '',
                textAlign: TextAlign.start,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDescContent(
                    desc: displayBio(),
                    trimLines: 5,
                    textAlign: TextAlign.start,
                    seeLess: ' ${notifier.language.seeLess}',
                    seeMore: ' ${notifier.language.seeMoreContent}',
                    normStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kHyppeLightSecondary),
                    hrefStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kHyppePrimary),
                    expandStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              )),
            ),
            displayPlace() != null
                ? Padding(
                    padding: EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
                    child: Row(
                      children: [
                        const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}pin.svg",
                          defaultColor: false,
                          color: kHyppeTextLightPrimary,
                        ),
                        CustomTextWidget(
                          textToDisplay: displayPlace() ?? '',
                          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            myEmail == email
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomElevatedButton(
                          width: 167 * SizeConfig.scaleDiagonal,
                          height: 42 * SizeConfig.scaleDiagonal,
                          buttonStyle: ButtonStyle(
                            backgroundColor: (notifier.statusFollowing == StatusFollowing.requested || notifier.statusFollowing == StatusFollowing.following)
                                ? null
                                : MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                          ),
                          function: notifier.isCheckLoading
                              ? null
                              : () {
                                  context.handleActionIsGuest(() {
                                    if (notifier.statusFollowing == StatusFollowing.none || notifier.statusFollowing == StatusFollowing.rejected) {
                                      notifier.followUser(context);
                                    } else if (notifier.statusFollowing == StatusFollowing.following) {
                                      notifier.followUser(context, isUnFollow: true);
                                    }
                                  });
                                },
                          child: notifier.isCheckLoading
                              ? const CustomLoading()
                              : CustomTextWidget(
                                  textToDisplay: notifier.statusFollowing == StatusFollowing.following
                                      ? notifier.language.following ?? 'following '
                                      : notifier.statusFollowing == StatusFollowing.requested
                                          ? notifier.language.requested ?? 'requested'
                                          : notifier.language.follow ?? 'follow',
                                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: (notifier.statusFollowing == StatusFollowing.requested || notifier.statusFollowing == StatusFollowing.following) ? kHyppeGrey : kHyppeLightButtonText,
                                      ),
                                ),
                        ),
                        CustomElevatedButton(
                          width: 167 * SizeConfig.scaleDiagonal,
                          height: 42 * SizeConfig.scaleDiagonal,
                          buttonStyle: Theme.of(context).elevatedButtonTheme.style,
                          function: () async {
                            context.handleActionIsGuest(() async {
                              if (notifier.manyUser.first.profile != null) {
                                try {
                                  await notifier.createDiscussion(context);
                                } catch (e) {
                                  e.logger();
                                }
                              } else {
                                // ShowBottomSheet.onInternalServerError(context, statusCode: 500, onReload: await notifier.createDiscussion(context));
                              }
                            });
                          },
                          child: CustomTextWidget(
                            textToDisplay: notifier.language.message ?? 'message',
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
