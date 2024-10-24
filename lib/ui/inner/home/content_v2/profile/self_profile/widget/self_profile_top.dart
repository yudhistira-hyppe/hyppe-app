import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/arguments/follower_screen_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/show_image_profile.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../constant/widget/custom_desc_content_widget.dart';

class SelfProfileTop extends StatelessWidget {
  const SelfProfileTop({
    Key? key,
  }) : super(key: key);

  void showTap(BuildContext context, List<ContentData> dataStory, SelfProfileNotifier notifier) {
    if (dataStory.isNotEmpty) {
      context.read<PreviewStoriesNotifier>().navigateToMyStoryGroup(context, dataStory, true);
    } else {
      showPict(context, notifier);
    }
  }

  void showPict(BuildContext context, SelfProfileNotifier notifier) {
    final imageUrl = notifier.displayPhotoProfileOriginal();
    print("gambar profil $imageUrl");
    // if (notifier.user.profile?.avatar?.mediaEndpoint?.isNotEmpty ?? false) {
    showDialog(
      context: context,
      builder: (context) {
        return ShowImageProfile(imageUrl: imageUrl!);
      },
      // barrierColor: Colors.red,
    );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final sn = Provider.of<PreviewStoriesNotifier>(context);
    final email = SharedPreference().readStorage(SpKeys.email);
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SelfProfileTop');

    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SelectableText("${notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}")}"),
            // SelectableText("${SharedPreference().readStorage(SpKeys.fcmToken)}"),
            // SelectableText("${System().getDeviceIdentifier().toString()}"),
            // GestureDetector(
            //   onTap: () {
            //     // Routing().move(Routes.streamer);
            //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => testAnimation()));
            //   },
            //   child: Text("stram"),
            // ),
            Row(
              children: <Widget>[
                // StoryColorValidator(
                //   haveStory: notifier.checkHaveStory(context),
                //   featureType: FeatureType.other,
                //   child: CustomProfileImage(
                //     cacheKey: notifier.user.profile?.avatar?.imageKey,
                //     following: true,
                //     width: 80 * SizeConfig.scaleDiagonal,
                //     height: 80 * SizeConfig.scaleDiagonal,
                //     imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                //     onTap: () => notifier.viewStory(context),
                //   ),
                // ),

                GestureDetector(
                  onTap: () {
                    showTap(context, sn.myStoryGroup[email] ?? [], notifier);
                  },
                  onLongPress: () {
                    showPict(context, notifier);
                  },
                  child: StoryColorValidator(
                    isMy: false,
                    haveStory: (sn.myStoryGroup[email]?.isEmpty ?? [].isEmpty) ? false : true,
                    featureType: (sn.myStoryGroup[email]?.isEmpty ?? [].isEmpty) ? FeatureType.other : FeatureType.story,
                    isView: (sn.myStoryGroup[email]?.isEmpty ?? [].isEmpty) ? false : (sn.myStoryGroup[email]?.last.isViewed ?? false),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CustomProfileImage(
                        cacheKey: notifier.user.profile?.avatar?.imageKey,
                        following: true,
                        forStory: true,
                        width: 76 * SizeConfig.scaleDiagonal,
                        height: 76 * SizeConfig.scaleDiagonal,
                        imageUrl: notifier.displayPhotoProfile("${notifier.user.profile?.avatar?.mediaEndpoint}"),
                        badge: notifier.user.profile?.urluserBadge,
                        allwaysUseBadgePadding: true,
                      ),
                    ),
                  ),
                ),
                fourteenPx,
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.displayPostsCount(),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                          CustomTextWidget(
                            textToDisplay: notifier.language.posts ?? 'Posts',
                            textStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Routing().move(
                            Routes.followerScreen,
                            argument: FollowerScreenArgument(
                              username: notifier.displayUserName(),
                              eventType: InteractiveEventType.follower,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            CustomTextWidget(
                              textToDisplay: notifier.displayFollowers(),
                              textStyle: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.followers ?? 'Followers',
                              textStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Routing().move(
                            Routes.followerScreen,
                            argument: FollowerScreenArgument(
                              username: notifier.displayUserName(),
                              eventType: InteractiveEventType.following,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            CustomTextWidget(
                              textToDisplay: notifier.displayFollowing(),
                              textStyle: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.following ?? 'Following',
                              textStyle: Theme.of(context).textTheme.bodyMedium!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.max,
            //   children: [
            //     StoryColorValidator(
            //       haveStory: notifier.checkHaveStory(context),
            //       featureType: FeatureType.other,
            //       child: CustomProfileImage(
            //         following: true,
            //         width: 80 * SizeConfig.scaleDiagonal,
            //         height: 80 * SizeConfig.scaleDiagonal,
            //         imageUrl: notifier.displayPhotoProfile(),
            //         onTap: () => notifier.viewStory(context),
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.only(left: 20),
            //       child: Expanded(
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Column(
            //               children: [
            //                 CustomTextWidget(
            //                   textToDisplay: notifier.displayPostsCount(),
            //                   textStyle: Theme.of(context).textTheme.subtitle1,
            //                 ),
            //                 SizedBox(height: 8 * SizeConfig.scaleDiagonal),
            //                 CustomTextWidget(
            //                   textToDisplay: notifier.language.posts,
            //                   textStyle: Theme.of(context)
            //                       .textTheme
            //                       .bodyText2!
            //                       .apply(
            //                           color: Theme.of(context)
            //                               .bottomNavigationBarTheme
            //                               .unselectedItemColor),
            //                 )
            //               ],
            //             ),
            //             SizedBox(width: 35 * SizeConfig.scaleDiagonal),
            //             InkWell(
            //               onTap: () {
            //                 Routing().move(
            //                   Routes.followerScreen,
            //                   argument: FollowerScreenArgument(
            //                     username: notifier.displayUserName(),
            //                     eventType: InteractiveEventType.follower,
            //                   ),
            //                 );
            //               },
            //               child: Column(
            //                 children: [
            //                   CustomTextWidget(
            //                     textToDisplay: notifier.displayFollowers(),
            //                     textStyle:
            //                         Theme.of(context).textTheme.subtitle1,
            //                   ),
            //                   SizedBox(height: 8 * SizeConfig.scaleDiagonal),
            //                   CustomTextWidget(
            //                     textToDisplay: notifier.language.followers,
            //                     textStyle: Theme.of(context)
            //                         .textTheme
            //                         .bodyText2!
            //                         .apply(
            //                             color: Theme.of(context)
            //                                 .bottomNavigationBarTheme
            //                                 .unselectedItemColor),
            //                   )
            //                 ],
            //               ),
            //             ),
            //             SizedBox(width: 35 * SizeConfig.scaleDiagonal),
            //             InkWell(
            //               onTap: () {
            //                 Routing().move(
            //                   Routes.followerScreen,
            //                   argument: FollowerScreenArgument(
            //                     username: notifier.displayUserName(),
            //                     eventType: InteractiveEventType.following,
            //                   ),
            //                 );
            //               },
            //               child: Column(
            //                 children: [
            //                   CustomTextWidget(
            //                     textToDisplay: notifier.displayFollowing(),
            //                     textStyle:
            //                         Theme.of(context).textTheme.subtitle1,
            //                   ),
            //                   SizedBox(height: 8 * SizeConfig.scaleDiagonal),
            //                   CustomTextWidget(
            //                     textToDisplay: notifier.language.following,
            //                     textStyle: Theme.of(context)
            //                         .textTheme
            //                         .bodyText2!
            //                         .apply(
            //                             color: Theme.of(context)
            //                                 .bottomNavigationBarTheme
            //                                 .unselectedItemColor),
            //                   )
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Padding(
              padding: EdgeInsets.only(top: 13 * SizeConfig.scaleDiagonal),
              child: CustomTextWidget(
                textToDisplay: notifier.displayFullName() ?? '',
                textAlign: TextAlign.start,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            notifier.isLoadingBio
                ? Builder(builder: (context) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      notifier.isLoadingBio = false;
                    });
                    return Container();
                  })
                : Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                    // color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDescContent(
                            desc: notifier.user.profile?.bio ?? '',
                            callback: (val) {},
                            callbackIsMore: (val) {},
                            trimLines: 3,
                            isloading: notifier.isLoadingBio,
                            textAlign: TextAlign.start,
                            seeLess: ' ${notifier.language.seeLess}',
                            seeMore: ' ${notifier.language.seeMoreContent}',
                            normStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kHyppeLightSecondary),
                            hrefStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kHyppePrimary),
                            expandStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                      ],
                    )),
                  ),
            notifier.displayPlace() != null
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
                          textToDisplay: notifier.displayPlace() ?? '',
                          textStyle: const TextStyle(),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            tenPx,
            if (notifier.user.profile?.urlLink != '')
              GestureDetector(
                onTap: () async {
                  var uri = notifier.user.profile!.urlLink ?? '';
                  if (!uri.withHttp()) {
                    uri = 'https://$uri';
                  }
                  if (await canLaunchUrl(Uri.parse(uri))) {
                    await launchUrl(Uri.parse(uri));
                  } else {
                    throw Fluttertoast.showToast(msg: 'Could not launch $uri');
                  }
                },
                child: SizedBox(
                  width: SizeConfig.screenWidth,
                  child: Row(
                    children: [
                      const CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}hyperlink.svg",
                        defaultColor: false,
                        color: kHyppePrimary,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      (notifier.user.profile?.judulLink != '')
                          ? Text(
                              notifier.user.profile?.judulLink ?? '',
                              style: const TextStyle(color: kHyppePrimary),
                            )
                          : Text(
                              notifier.user.profile?.urlLink ?? '',
                              style: const TextStyle(color: kHyppePrimary),
                            )
                    ],
                  ),
                ),
              ),
            Padding(
                padding: EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      // when button library is active, remove this expanded and set width value
                      child: CustomElevatedButton(
                        width: null,
                        height: 42 * SizeConfig.scaleDiagonal,
                        buttonStyle: Theme.of(context).elevatedButtonTheme.style,
                        function: () => notifier.navigateToEditProfile(),
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.editProfile ?? '',
                          textStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ),
                    sixPx,
                    notifier.statusKyc == VERIFIED
                        ? CustomElevatedButton(
                            width: 167 * SizeConfig.scaleDiagonal,
                            height: 42 * SizeConfig.scaleDiagonal,
                            buttonStyle: Theme.of(context).elevatedButtonTheme.style,
                            function: () => Routing().move(Routes.boostList),
                            child: CustomTextWidget(
                              textToDisplay: notifier.language.boostedPostList ?? 'Boosted List',
                              textStyle: Theme.of(context).textTheme.labelLarge,
                            ),
                          )
                        : Container()
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
