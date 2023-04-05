import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/kyc_status.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/button_boost.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_like_animation.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/no_result_found.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/core/constants/enum.dart';

import '../../../../constant/entities/like/notifier.dart';

class HyppePreviewVid extends StatefulWidget {
  const HyppePreviewVid({Key? key}) : super(key: key);

  @override
  _HyppePreviewVidState createState() => _HyppePreviewVidState();
}

class _HyppePreviewVidState extends State<HyppePreviewVid> {
  String email = '';
  LocalizationModelV2? lang;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HyppePreviewVid');
    email = SharedPreference().readStorage(SpKeys.email);
    final notifier = Provider.of<PreviewVidNotifier>(context, listen: false);
    // notifier.initialVid(context, reload: true);
    notifier.pageController.addListener(() => notifier.scrollListener(context));
    lang = context.read<TranslateNotifierV2>().translate;
    super.initState();
  }

  @override
  void dispose() {
    try {
      final notifier = context.read<PreviewVidNotifier>();
      notifier.pageController.dispose();
    } catch (e) {
      e.logger();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final vidNotifier = context.watch<PreviewVidNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.vid));
    // final likeNotifier = Provider.of<LikeNotifier>(context, listen: false);

    return Consumer3<PreviewVidNotifier, TranslateNotifierV2, HomeNotifier>(
      builder: (context, vidNotifier, translateNotifier, homeNotifier, widget) => SizedBox(
        child: Column(
          children: [
            (vidNotifier.vidData != null)
                ? (vidNotifier.vidData?.isEmpty ?? true)
                    ? const NoResultFound()
                    : Expanded(
                        child: NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return false;
                          },
                          child: ListView.builder(
                            // controller: vidNotifier.pageController,
                            // onPageChanged: (index) async {
                            //   print('HyppePreviewVid index : $index');
                            //   if (index == (vidNotifier.itemCount - 1)) {
                            //     final values = await vidNotifier.contentsQuery.loadNext(context, isLandingPage: true);
                            //     if (values.isNotEmpty) {
                            //       vidNotifier.vidData = [...(vidNotifier.vidData ?? [] as List<ContentData>)] + values;
                            //     }
                            //   }
                            //   // context.read<PreviewVidNotifier>().nextVideo = false;
                            //   // context.read<PreviewVidNotifier>().initializeVideo = false;
                            // },
                            shrinkWrap: true,
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

                              return itemVid(vidData ?? ContentData(), vidNotifier);
                            },
                          ),
                        ),
                      )
                : const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomShimmer(
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
            homeNotifier.isLoadingLoadmore
                ? const SizedBox(
                    height: 50,
                    child: CustomLoading(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget itemVid(ContentData vidData, PreviewVidNotifier vidNotifier) {
    return GestureDetector(
      onTap: () {
        vidNotifier.navigateToHyppeVidDetail(context, vidData, fromLAnding: true);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ProfileLandingPage(
                    show: true,
                    // cacheKey: vidData?.email == email ? homeNotifier.profileImageKey : null,
                    onFollow: () {},
                    following: true,
                    haveStory: false,
                    textColor: kHyppeTextLightPrimary,
                    username: vidData.username,
                    featureType: FeatureType.other,
                    // isCelebrity: vidvidData?.privacy?.isCelebrity,
                    isCelebrity: false,
                    imageUrl: '${System().showUserPicture(vidData.avatar?.mediaEndpoint)}',
                    onTapOnProfileImage: () => System().navigateToProfile(context, vidData.email ?? ''),
                    createdAt: '2022-02-02',
                    musicName: vidData.music?.musicTitle ?? '',
                    location: vidData.location ?? '',
                    isIdVerified: vidData.privacy?.isIdVerified,
                  ),
                ),
                if (vidData.email != email && (vidData.isNewFollowing ?? false))
                  Consumer<PreviewPicNotifier>(
                    builder: (context, picNot, child) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (vidData.insight?.isloadingFollow != true) {
                            picNot.followUser(context, vidData, isUnFollow: vidData.following, isloading: vidData.insight!.isloadingFollow ?? false);
                          }
                        },
                        child: vidData.insight?.isloadingFollow ?? false
                            ? Container(
                                height: 40,
                                width: 30,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: CustomLoading(),
                                ),
                              )
                            : Text(
                                (vidData.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                                style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                              ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    if (vidData.email != SharedPreference().readStorage(SpKeys.email)) {
                      vidNotifier.reportContent(context, vidData);
                    } else {
                      ShowBottomSheet().onShowOptionContent(
                        context,
                        contentData: vidData,
                        captionTitle: hyppeVid,
                        onDetail: false,
                        isShare: vidData.isShared,
                        onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.more_vert,
                    color: kHyppeTextLightPrimary,
                  ),
                ),
              ],
            ),
            twelvePx,
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    child: CustomBaseCacheImage(
                      memCacheWidth: 100,
                      memCacheHeight: 100,
                      widthPlaceHolder: 80,
                      heightPlaceHolder: 80,
                      imageUrl: (vidData.isApsara ?? false) ? (vidData.mediaThumbEndPoint ?? "") : "${vidData.fullThumbPath}",
                      imageBuilder: (context, imageProvider) => Container(
                        // const EdgeInsets.symmetric(horizontal: 4.5),
                        width: SizeConfig.screenWidth,
                        height: SizeConfig.screenWidth! / 1.5,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          // const EdgeInsets.symmetric(horizontal: 4.5),

                          height: 186,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('${AssetPath.pngPath}content-error.png'),
                              fit: BoxFit.contain,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        );
                      },
                      emptyWidget: Container(
                        // const EdgeInsets.symmetric(horizontal: 4.5),

                        height: 186,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('${AssetPath.pngPath}content-error.png'),
                            fit: BoxFit.contain,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                AspectRatio(aspectRatio: 16 / 9, child: _buildBody(context, vidData, SizeConfig.screenWidth)),
              ],
            ),
            // (vidData?.tagPeople?.isNotEmpty ?? false) || vidData?.location != ''
            //     ? Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 10.0),
            //         child: Row(
            //           children: [
            //             vidData?.tagPeople?.isNotEmpty ?? false
            //                 ? TagLabel(
            //                     icon: 'tag_people',
            //                     label: '${vidData?.tagPeople?.length} people',
            //                     function: () {
            //                       vidNotifier.showUserTag(context, index, vidData?.postID);
            //                     },
            //                   )
            //                 : const SizedBox(),
            //             vidData?.location == '' || vidData?.location == null
            //                 ? const SizedBox()
            //                 : TagLabel(
            //                     icon: 'maptag',
            //                     label: "${vidData?.location}",
            //                     function: () {},
            //                   ),
            //           ],
            //         ),
            //       )
            //     : const SizedBox(),
            SharedPreference().readStorage(SpKeys.statusVerificationId) == VERIFIED &&
                    (vidData.boosted.isEmpty) &&
                    (vidData.reportedStatus != 'OWNED' && vidData.reportedStatus != 'BLURRED' && vidData.reportedStatus2 != 'BLURRED') &&
                    vidData.email == email
                ? Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.only(top: 10),
                    child: ButtonBoost(
                      onDetail: false,
                      marginBool: true,
                      contentData: vidData,
                      startState: () {
                        SharedPreference().writeStorage(SpKeys.isShowPopAds, true);
                      },
                      afterState: () {
                        SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
                      },
                    ),
                  )
                : Container(),
            if (vidData.email == email && (vidData.boostCount ?? 0) >= 0 && (vidData.boosted.isNotEmpty))
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: kHyppeGreyLight,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}reach.svg",
                      defaultColor: false,
                      height: 24,
                      color: kHyppeTextLightPrimary,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 13),
                      child: Text(
                        "${vidData.boostJangkauan ?? '0'} ${lang?.reach}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppeTextLightPrimary),
                      ),
                    )
                  ],
                ),
              ),
            twelvePx,
            CustomNewDescContent(
              // desc: "${data?.description}",
              username: '',
              desc: "${vidData.description}",
              trimLines: 2,
              textAlign: TextAlign.start,
              seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
              seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
              normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
              hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
              expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            eightPx,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "${System().readTimestamp(
                  DateTime.parse(System().dateTimeRemoveT(vidData.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                  context,
                  fullCaption: true,
                )}",
                style: const TextStyle(fontSize: 12, color: kHyppeBurem),
              ),
            ),
            // vidData?.email == SharedPreference().readStorage(SpKeys.email) ? ButtonBoost(contentData: vidData) : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(context, data, width) {
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Stack(
      children: [
        PicTopItem(data: data),
        if (data?.tagPeople?.isNotEmpty ?? false)
          Positioned(
            bottom: 18,
            left: 12,
            child: GestureDetector(
              onTap: () {
                context.read<PicDetailNotifier>().showUserTag(context, data?.tagPeople, data?.postID);
              },
              child: const CustomIconWidget(
                iconData: '${AssetPath.vectorPath}tag_people.svg',
                defaultColor: false,
                height: 20,
              ),
            ),
          ),

        Positioned(
            bottom: 18,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                System().formatDuration(Duration(seconds: data?.metadata?.duration ?? 0).inMilliseconds),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            )),
        // Positioned(bottom: 0, left: 0, child: PicBottomItem(data: data, width: width)),
        data?.reportedStatus == 'BLURRED'
            ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 30.0,
                    sigmaY: 30.0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: SizeConfig.screenWidth,
                    height: 200.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}eye-off.svg",
                          defaultColor: false,
                          height: 50,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
