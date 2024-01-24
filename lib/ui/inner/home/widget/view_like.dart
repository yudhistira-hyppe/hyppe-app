import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/custom_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ViewLiked extends StatefulWidget {
  final String postId;
  final String eventType;
  const ViewLiked({super.key, required this.postId, required this.eventType});

  @override
  State<ViewLiked> createState() => _ViewLikedState();
}

class _ViewLikedState extends State<ViewLiked> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    var likeNotifier = Provider.of<LikeNotifier>(context, listen: false);
    likeNotifier.initViews(widget.postId, widget.eventType);
    _scrollController.addListener(() => likeNotifier.scrollListLikeView(context, _scrollController, widget.postId, widget.eventType, 20));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TranslateNotifierV2 lang = context.read<TranslateNotifierV2>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kHyppeLightBackground,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Routing().moveBack();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
        title: Text(widget.eventType == 'LIKE' ? lang.translate.like!.capitalized : lang.translate.views!.capitalized),
      ),
      body: Container(
        color: kHyppeLightBackground,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Consumer<LikeNotifier>(
              builder: (context, notifier, child) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: notifier.isLoading
                        ? SizedBox(height: SizeConfig.screenHeight! - kToolbarHeight, child: const Center(child: CustomLoading()))
                        : notifier.listLikeView == null
                            ? Container(
                                alignment: Alignment.center,
                                height: SizeConfig.screenHeight! - kToolbarHeight,
                                child: Text(
                                  widget.eventType == 'LIKE' ? lang.translate.notLikeyet! : lang.translate.notviewyet!,
                                  textAlign: TextAlign.center,
                                ))
                            : notifier.listLikeView?.user != null && (notifier.listLikeView!.user!.isNotEmpty)
                                ? Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        controller: _scrollController,
                                        itemCount: notifier.listLikeView?.user?.length,
                                        itemBuilder: (context, index) {
                                          final data = notifier.listLikeView?.user?[index];
                                          if (data != null) {
                                            return ListTile(
                                                onTap: () => System().navigateToProfile(context, data.email ?? ''),
                                                contentPadding: EdgeInsets.zero,
                                                leading: StoryColorValidator(
                                                  haveStory: false,
                                                  featureType: FeatureType.pic,
                                                  child: CustomProfileImage(
                                                    width: 40,
                                                    height: 40,
                                                    onTap: () => System().navigateToProfile(context, data.email ?? ''),
                                                    imageUrl: System().showUserPicture(data.avatar == null ? '' : data.avatar?.mediaEndpoint),
                                                    badge: data.urluserBadge,
                                                    following: true,
                                                    onFollow: () {},
                                                  ),
                                                ),
                                                title: CustomTextWidget(
                                                  textToDisplay: data.username ?? '',
                                                  textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                                  textAlign: TextAlign.start,
                                                ),
                                                subtitle: CustomTextWidget(
                                                  textToDisplay: data.fullName.capitalized,
                                                  // textStyle: Theme.of(context).textTheme.titleSmall,
                                                  textAlign: TextAlign.start,
                                                ),
                                                trailing: System().isMy(data.email)
                                                    ? const SizedBox(
                                                        height: 40,
                                                        width: 30,
                                                      )
                                                    : CustomElevatedButton(
                                                        width: 100,
                                                        height: 24,
                                                        buttonStyle: ButtonStyle(
                                                          backgroundColor: (data.following ?? false) ? null : MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                                                        ),
                                                        function: () {
                                                          if (!(data.isloadingFollow ?? false)) {
                                                            if (data.following ?? false) {
                                                              notifier.followUserLikeView(context, data, isUnFollow: true);
                                                            } else {
                                                              notifier.followUserLikeView(context, data);
                                                            }
                                                          }
                                                        },
                                                        child: data.isloadingFollow ?? false
                                                            ? const SizedBox(
                                                                height: 40,
                                                                width: 30,
                                                                child: Align(
                                                                  alignment: Alignment.bottomRight,
                                                                  child: CustomLoading(),
                                                                ),
                                                              )
                                                            : CustomTextWidget(
                                                                textToDisplay: (data.following ?? false) ? lang.translate.following! : lang.translate.follow!,
                                                                textStyle: Theme.of(context)
                                                                    .textTheme
                                                                    .labelLarge
                                                                    ?.copyWith(color: (data.following ?? false) ? kHyppeTextLightPrimary : kHyppeLightButtonText))));
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      if ((notifier.listLikeView?.guest ?? 0) > 0)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: StoryColorValidator(
                                            haveStory: false,
                                            featureType: FeatureType.pic,
                                            child: CustomProfileImage(
                                              width: 40,
                                              height: 40,
                                              onTap: null,
                                              imageUrl: '',
                                              badge: null,
                                              following: true,
                                              onFollow: () {},
                                            ),
                                          ),
                                          title: CustomTextWidget(
                                            textToDisplay: 'Guest mode',
                                            textStyle: Theme.of(context).textTheme.titleSmall,
                                            textAlign: TextAlign.start,
                                          ),
                                          trailing: CustomTextWidget(
                                            textToDisplay: '${notifier.listLikeView?.guest}',
                                            textStyle: Theme.of(context).textTheme.titleSmall,
                                            textAlign: TextAlign.start,
                                          ),
                                        )
                                    ],
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    height: SizeConfig.screenHeight! - kToolbarHeight,
                                    child: Text(
                                      widget.eventType == 'LIKE' ? lang.translate.notLikeyet! : lang.translate.notviewyet!,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                  )),
        ),
      ),
    );
  }
}
