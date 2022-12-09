import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class OtherProfileTop extends StatelessWidget {
  const OtherProfileTop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OtherProfileNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: EdgeInsets.only(top: 16.0 * SizeConfig.scaleDiagonal, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          children: [
                            CustomTextWidget(
                              textToDisplay: notifier.displayPostsCount(),
                              textStyle: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.posts ?? 'Posts',
                              textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            CustomTextWidget(
                              textToDisplay: notifier.displayFollowers(),
                              textStyle: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.followers ?? 'Followers',
                              textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            CustomTextWidget(
                              textToDisplay: notifier.displayFollowing(),
                              textStyle: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(height: 8 * SizeConfig.scaleDiagonal),
                            CustomTextWidget(
                              textToDisplay: notifier.language.following ?? 'Following',
                              textStyle: Theme.of(context).textTheme.bodyText2!.apply(color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor),
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
                textToDisplay: notifier.displayFullName() ?? '',
                textAlign: TextAlign.start,
                textStyle: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            notifier.displayBio().length > 2
                ? Container(
                    padding: const EdgeInsets.all(2),
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.2),
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReadMoreText(
                          notifier.displayBio(),
                          // "${widget.arguments?.description} ${widget.arguments?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" ")}",
                          trimLines: 5,
                          trimMode: TrimMode.Line,
                          textAlign: TextAlign.start,
                          trimExpandedText: 'Show less',
                          trimCollapsedText: 'Show more',
                          colorClickableText: Theme.of(context).colorScheme.primaryVariant,
                          style: Theme.of(context).textTheme.bodyText2!.copyWith(),
                          moreStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                          lessStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                        ),
                      ],
                    )),
                  )
                : const SizedBox.shrink(),
            notifier.displayPlace() != null
                ? Padding(
                    padding: EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
                    child: Row(
                      children: [
                        const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}pin.svg",
                          defaultColor: false,
                          color: kHyppePrimary,
                        ),
                        CustomTextWidget(
                          textToDisplay: notifier.displayPlace() ?? '',
                          textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: kHyppePrimary),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: EdgeInsets.only(top: 12 * SizeConfig.scaleDiagonal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomElevatedButton(
                    child: notifier.isCheckLoading
                        ? const CustomLoading()
                        : CustomTextWidget(
                            textToDisplay: notifier.statusFollowing == StatusFollowing.following
                                ? notifier.language.following ?? 'following'
                                : notifier.statusFollowing == StatusFollowing.requested
                                    ? notifier.language.requested ?? 'requested'
                                    : notifier.language.follow ?? 'follow',
                            textStyle: Theme.of(context).textTheme.button?.copyWith(
                                  color: notifier.statusFollowing == StatusFollowing.requested ? null : kHyppeLightButtonText,
                                ),
                          ),
                    width: 167 * SizeConfig.scaleDiagonal,
                    height: 42 * SizeConfig.scaleDiagonal,
                    buttonStyle: ButtonStyle(
                      backgroundColor: notifier.statusFollowing == StatusFollowing.requested ? null : MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                    ),
                    function: notifier.isCheckLoading
                        ? null
                        : () {
                            if (notifier.statusFollowing == StatusFollowing.none || notifier.statusFollowing == StatusFollowing.rejected) {
                              notifier.followUser(context);
                            }
                          },
                  ),
                  CustomElevatedButton(
                    child: CustomTextWidget(
                      textToDisplay: notifier.language.message ?? 'message',
                      textStyle: Theme.of(context).textTheme.button,
                    ),
                    width: 167 * SizeConfig.scaleDiagonal,
                    height: 42 * SizeConfig.scaleDiagonal,
                    buttonStyle: Theme.of(context).elevatedButtonTheme.style,
                    function: () async {
                      if (notifier.user.profile != null) {
                        try {
                          await notifier.createDiscussion(context);
                        } catch (e) {
                          e.logger();
                        }
                      } else {
                        ShowBottomSheet.onInternalServerError(context, tryAgainButton: () => Routing().moveBack());
                      }
                    },
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
