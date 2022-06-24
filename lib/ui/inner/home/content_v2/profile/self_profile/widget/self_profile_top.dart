import 'package:hyppe/core/arguments/follower_screen_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelfProfileTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SelectableText("${notifier.displayPhotoProfile()}"),
            Row(
              children: <Widget>[
                StoryColorValidator(
                  haveStory: notifier.checkHaveStory(context),
                  featureType: FeatureType.other,
                  child: CustomProfileImage(
                    following: true,
                    width: 80 * SizeConfig.scaleDiagonal,
                    height: 80 * SizeConfig.scaleDiagonal,
                    imageUrl: notifier.displayPhotoProfile(),
                    onTap: () => notifier.viewStory(context),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.displayPostsCount(),
                            textStyle: Theme.of(context).textTheme.subtitle1,
                          ),
                          SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                          CustomTextWidget(
                            textToDisplay: notifier.language.posts!,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .apply(
                                    color: Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .unselectedItemColor),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.displayPostsCount(),
                            textStyle: Theme.of(context).textTheme.subtitle1,
                          ),
                          SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                          CustomTextWidget(
                            textToDisplay: notifier.language.posts!,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .apply(
                                    color: Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .unselectedItemColor),
                          )
                        ],
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
                              textStyle: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.following!,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .apply(
                                      color: Theme.of(context)
                                          .bottomNavigationBarTheme
                                          .unselectedItemColor),
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
            //                   textToDisplay: notifier.language.posts!,
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
            //                     textToDisplay: notifier.language.followers!,
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
            //                     textToDisplay: notifier.language.following!,
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
                textToDisplay: notifier.displayFullName()!,
                textAlign: TextAlign.start,
                textStyle: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            notifier.displayBio().length > 2
                ? Padding(
                    padding: EdgeInsets.only(top: 8 * SizeConfig.scaleDiagonal),
                    child: CustomTextWidget(
                      textToDisplay: notifier.displayBio(),
                      textAlign: TextAlign.start,
                      textStyle: Theme.of(context).textTheme.bodyText2,
                      // maxLines: notifier.maxLine,
                    ),
                  )
                : const SizedBox.shrink(),
            notifier.displayPlace() != null
                ? Padding(
                    padding:
                        EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
                    child: Row(
                      children: [
                        const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}pin.svg",
                          defaultColor: false,
                          color: kHyppePrimary,
                        ),
                        CustomTextWidget(
                          textToDisplay: notifier.displayPlace()!,
                          textStyle: const TextStyle(color: kHyppePrimary),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
                padding: EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      // when button library is active, remove this expanded and set width value
                      child: CustomElevatedButton(
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.editProfile!,
                          textStyle: Theme.of(context).textTheme.button,
                        ),
                        width: null,
                        height: 42 * SizeConfig.scaleDiagonal,
                        buttonStyle:
                            Theme.of(context).elevatedButtonTheme.style,
                        function: () => notifier.navigateToEditProfile(),
                      ),
                    ),
                    // CustomElevatedButton(
                    //   child: CustomTextWidget(
                    //     textToDisplay: "Library",
                    //     textStyle: Theme.of(context).textTheme.button,
                    //   ),
                    //   width: 167 * SizeConfig.scaleDiagonal,
                    //   height: 42 * SizeConfig.scaleDiagonal,
                    //   buttonStyle: Theme.of(context).elevatedButtonTheme.style,
                    //   function: () {},
                    // )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
