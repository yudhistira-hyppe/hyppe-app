import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class OnShowUserTagBottomSheet extends StatefulWidget {
  final List<TagPeople> value;
  final Function() function;
  final String postId;
  final String? title;
  const OnShowUserTagBottomSheet({
    Key? key,
    required this.value,
    required this.function,
    required this.postId,
    this.title,
  }) : super(key: key);

  @override
  State<OnShowUserTagBottomSheet> createState() => _OnShowUserTagBottomSheetState();
}

class _OnShowUserTagBottomSheetState extends State<OnShowUserTagBottomSheet> with AfterFirstLayoutMixin {
  // final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? lastInputValue;

  @override
  void afterFirstLayout(BuildContext context) {
    context.read<LikeNotifier>().getTagPeople(context, widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer3<FollowRequestUnfollowNotifier, LikeNotifier, TranslateNotifierV2>(
      builder: (context, notifier, notifierTag, notifierTranslate, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Center(child: CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg")),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: CustomTextWidget(
                    textToDisplay: widget.title ?? hyppeVid,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              notifierTag.isLoading
                  ? Center(child: CustomLoading())
                  : ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemCount: notifierTag.listTagPeople.length,
                      itemBuilder: (context, index) {
                        // print(System().showUserPicture(value[index].avatar));
                        notifierTag.listTagPeople[index].status == 'UNLINK' ? '' : notifier.setStatusFollow(System().getEnumFollowStatus(notifierTag.listTagPeople[index].status ?? ''));
                        return Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                await System().navigateToProfile(context, notifierTag.listTagPeople[index].email ?? '');
                                if (mounted) Navigator.pop(context);
                              },
                              contentPadding: EdgeInsets.zero,
                              title: CustomTextWidget(
                                textToDisplay: notifierTag.listTagPeople[index].username ?? '',
                                textStyle: Theme.of(context).textTheme.titleSmall,
                                textAlign: TextAlign.start,
                              ),
                              // subtitle: Text("${notifier.searchPeolpleData[index].fullName}"),
                              trailing: notifierTag.listTagPeople[index].status == 'UNLINK'
                                  ? const SizedBox()
                                  : notifier.emailcheck(notifierTag.listTagPeople[index].email)
                                      ? SizedBox(
                                          width: 100,
                                          child: CustomTextButton(
                                            onPressed: () {
                                              Routing().moveBack();
                                              ShowGeneralDialog.deleteTagUserContentDialog(context, '', () {}, widget.postId);
                                            },
                                            child: Text(
                                              notifierTranslate.translate.delete ?? 'delete',
                                              style: const TextStyle(color: kHyppePrimary),
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          width: 100,
                                          child: Builder(builder: (context) {
                                            final actionFollowOfUn = notifierTag.listTagPeople[index].status == 'FOLLOWING'
                                                ? () {
                                                    print("asdads");
                                                    notifier.followUser(context, email: notifierTag.listTagPeople[index].email, index: index, isUnFollow: true).then((value) {
                                                      if (value) {
                                                        notifierTag.listTagPeople[index].status = 'TOFOLLOW';
                                                        setState(() {});
                                                      }
                                                    });
                                                  }
                                                : notifierTag.listTagPeople[index].status == 'TOFOLLOW'
                                                    ? () {
                                                        context.handleActionIsGuest(() {
                                                          notifier.followUser(context, email: notifierTag.listTagPeople[index].email, index: index).then((value) {
                                                            if (value) {
                                                              notifierTag.listTagPeople[index].status = 'FOLLOWING';
                                                              setState(() {});
                                                            }
                                                          });
                                                        });
                                                      }
                                                    : null;
                                            return CustomTextButton(
                                              child: notifier.isLoading
                                                  ? SizedBox(width: 15, height: 20, child: CustomLoading())
                                                  : Text(
                                                      System().getValueStringFollow(notifier.statusFollow, context.read<TranslateNotifierV2>().translate),
                                                      style: TextStyle(color: notifierTag.listTagPeople[index].status == 'TOFOLLOW' ? kHyppeTextPrimary : kHyppeLightSecondary),
                                                    ),
                                              onPressed: actionFollowOfUn,
                                              style: notifierTag.listTagPeople[index].status == 'TOFOLLOW'
                                                  ? ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary))
                                                  : ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppeLightInactive1)),
                                            );
                                          }),
                                        ),

                              leading: StoryColorValidator(
                                haveStory: false,
                                featureType: FeatureType.pic,
                                child: CustomProfileImage(
                                  width: 40,
                                  height: 40,
                                  onTap: () {},
                                  imageUrl: System().showUserPicture(notifierTag.listTagPeople[index].avatar == null ? '' : notifierTag.listTagPeople[index].avatar?.mediaEndpoint),
                                  badge: notifierTag.listTagPeople[index].urluserBadge,
                                  following: true,
                                  onFollow: () {},
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
            ],
          ),
        ),
      ),
    );
  }
}
