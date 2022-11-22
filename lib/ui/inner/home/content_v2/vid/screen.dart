import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/tag_label.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_header_feature.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/widget/video_player_page.dart';

class HyppePreviewVid extends StatefulWidget {
  const HyppePreviewVid({Key? key}) : super(key: key);

  @override
  _HyppePreviewVidState createState() => _HyppePreviewVidState();
}

class _HyppePreviewVidState extends State<HyppePreviewVid> {
  @override
  void initState() {
    final notifier = Provider.of<PreviewVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    notifier.pageController.addListener(() => notifier.scrollListener(context));
    super.initState();
  }


  @override
  void dispose() {
    final notifier = Provider.of<PreviewVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    notifier.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final vidNotifier = context.watch<PreviewVidNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.vid));
    final likeNotifier = Provider.of<LikeNotifier>(context, listen: false);

    return Consumer3<PreviewVidNotifier, TranslateNotifierV2, HomeNotifier>(
      builder: (context, vidNotifier, translateNotifier, homeNotifier, widget) => SizedBox(
        width: SizeConfig.screenWidth,
        child: Column(
          children: [
            CustomHeaderFeature(
              onPressed: () => vidNotifier.navigateToSeeAll(context),
              title: context.read<TranslateNotifierV2>().translate.latestVidsForYou ?? '',
            ),
            twelvePx,
            context.read<ErrorService>().isInitialError(error, vidNotifier.vidData)
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomErrorWidget(
                      errorType: ErrorType.vid,
                      function: () => context.read<PreviewVidNotifier>().initialVid(context, reload: true),
                    ),
                  )
                : (vidNotifier.vidData != null)
                    ? vidNotifier.vidData?.isEmpty ?? true
                        ? const NoResultFound()
                        : SizedBox(
                            height: 350,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo is ScrollStartNotification) {
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    vidNotifier.initialVid(context);
                                  });
                                }
                                return true;
                              },
                              child: PageView.builder(
                                controller: vidNotifier.pageController,
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index) {
                                  // context.read<PreviewVidNotifier>().nextVideo = false;
                                  // context.read<PreviewVidNotifier>().initializeVideo = false;
                                },
                                itemCount: vidNotifier.itemCount,
                                itemBuilder: (BuildContext context, int index) {
                                  if (homeNotifier.isLoadingVid) {
                                    return CustomShimmer(
                                      margin: const EdgeInsets.only(bottom: 100, right: 16, left: 16),
                                      height: context.getHeight() / 8,
                                      width: double.infinity,
                                    );
                                  }
                                  if (index == vidNotifier.vidData?.length && vidNotifier.hasNext) {
                                    return const CustomLoading(size: 5);
                                  }
                                  final vidData = vidNotifier.vidData?[index];
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // SelectableText("${System().showUserPicture(vidData?.avatar?.mediaEndpoint)}"),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Consumer<FollowRequestUnfollowNotifier>(
                                              builder: (context, value, child) {
                                                return ProfileComponent(
                                                  show: true,
                                                  onFollow: () {},
                                                  following: true,
                                                  haveStory: false,
                                                  username: vidData?.username,
                                                  featureType: FeatureType.vid,
                                                  isCelebrity: vidData?.privacy?.isCelebrity,
                                                  imageUrl: '${System().showUserPicture(vidData?.avatar?.mediaEndpoint)}',
                                                  onTapOnProfileImage: () => System().navigateToProfile(context, vidData?.email ?? ''),
                                                  createdAt: '${System().readTimestamp(
                                                    DateTime.parse(vidData?.createdAt ?? DateTime.now().toString()).millisecondsSinceEpoch,
                                                    context,
                                                    fullCaption: true,
                                                  )}',
                                                );
                                              },
                                            ),
                                            GestureDetector(
                                                onTap: () => vidNotifier.reportContent(context, vidNotifier.vidData?[index] ?? ContentData()),
                                                child: Visibility(
                                                  visible: vidData?.email != SharedPreference().readStorage(SpKeys.email),
                                                  child: const Icon(Icons.more_vert),
                                                )),
                                          ],
                                        ),
                                      ),
                                      twelvePx,
                                      // Consumer<PreviewVidNotifier>(
                                      //   builder: (context, value, _) {
                                      //     return Column(
                                      //       children: [
                                      //         Text("${value.vidData?[index].username}"),
                                      //         InkWell(
                                      //           onTap: () {
                                      //             value.vidData?[index].username = 'hahahaha';
                                      //           },
                                      //           child: Text('asd'),
                                      //         ),
                                      //       ],
                                      //     );
                                      //   },
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Stack(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Colors.black,
                                                ),
                                                child: VideoPlayerPage(
                                                  onDetail: false,
                                                  videoData: vidNotifier.vidData?[index],
                                                  key: ValueKey(vidNotifier.vidPostState),
                                                  afterView: () => System().increaseViewCount(context, vidNotifier.vidData?[index] ?? ContentData()),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      vidData?.tagPeople?.isNotEmpty ?? false || vidData?.location != ''
                                          ? Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 10.0),
                                              child: Row(
                                                children: [
                                                  vidData?.tagPeople?.isNotEmpty ?? false
                                                      ? TagLabel(
                                                          icon: 'user',
                                                          label: '${vidData?.tagPeople?.length} people',
                                                          function: () {
                                                            vidNotifier.showUserTag(context, index, vidData?.postID);
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                  vidData?.location == '' || vidData?.location == null
                                                      ? const SizedBox()
                                                      : TagLabel(
                                                          icon: 'maptag',
                                                          label: "${vidData?.location}",
                                                          function: () {},
                                                        ),
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                vidNotifier.navigateToHyppeVidDetail(context, vidData);
                                              },
                                              child: SizedBox(
                                                width: 240,
                                                child: CustomTextWidget(
                                                  maxLines: 2,
                                                  textAlign: TextAlign.left,
                                                  // textToDisplay: "${vidData?.description} ${vidData?.tags?.map((e) => "#${e.replaceFirst('#', '')}").join(" ")}",
                                                  textToDisplay: "${vidData?.description}",
                                                  textStyle: Theme.of(context).textTheme.caption,
                                                ),
                                              ),
                                            ),
                                            Consumer<LikeNotifier>(
                                              builder: (context, notifier, child) => Align(
                                                alignment: Alignment.bottomRight,
                                                child: InkWell(
                                                  child: CustomIconWidget(
                                                    defaultColor: false,
                                                    color: (vidData?.insight?.isPostLiked ?? false) ? kHyppePrimary : Theme.of(context).iconTheme.color,
                                                    iconData: '${AssetPath.vectorPath}${(vidData?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                                                  ),
                                                  onTap: (){
                                                    if(vidData != null){
                                                      notifier.likePost(context, vidData);
                                                    }

                                                  } ,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                    : const AspectRatio(
                        child: CustomShimmer(
                          height: double.infinity,
                          width: double.infinity,
                        ),
                        aspectRatio: 16 / 9,
                      )
          ],
        ),
      ),
    );
  }
}
