import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_follow_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:provider/provider.dart';

// import 'package:hyppe/ui/inner/home/content/pic/widget/pic_top_item.dart';

class PicCenterItem extends StatelessWidget {
  final Function? onTap;
  final ContentData? data;
  final EdgeInsets? margin;
  final LocalizationModelV2? lang;

  const PicCenterItem({Key? key, this.onTap, this.data, this.margin, this.lang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaling = (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2;
    // 'mediaThumbEndPoint : ${data?.mediaThumbEndPoint} , ${data?.mediaEndpoint}. ${data?.postID}'.logger();
    var statusFollowing = (data?.following ?? false) ? StatusFollowing.following : StatusFollowing.none;
    var email = SharedPreference().readStorage(SpKeys.email);
    int followTriger = 0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
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
                  username: data?.username,
                  featureType: FeatureType.other,
                  // isCelebrity: vidData?.privacy?.isCelebrity,
                  isCelebrity: false,
                  imageUrl: '${System().showUserPicture(data?.avatar?.mediaEndpoint)}',
                  // onTapOnProfileImage: () => System().navigateToProfile(context, vidData?.email ?? '', isReplaced: false),
                  onTapOnProfileImage: () {},
                  createdAt: '2022-02-02',
                  musicName: data?.music?.musicTitle ?? '',
                  location: data?.location ?? '',
                ),
              ),
              Text("$followTriger"),
              Consumer3<PicDetailNotifier, FollowRequestUnfollowNotifier, TranslateNotifierV2>(
                builder: (context, value, value2, value3, child) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (followTriger == 0) value.statusFollowing = statusFollowing;
                  });

                  if (data?.email == email) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      data?.insight?.isloadingFollow ?? false
                          ? const Center(child: SizedBox(height: 40, child: CustomLoading()))
                          : CustomFollowButton(
                              checkIsLoading: data?.insight?.isloadingFollow ?? false,
                              onPressed: () async {
                                try {
                                  data?.insight?.isloadingFollow = true;
                                  await value.followUser(context, isUnFollow: value.statusFollowing == StatusFollowing.following, receiverParty: data?.email ?? '');
                                  data?.insight?.isloadingFollow = false;
                                  followTriger++;
                                } catch (e) {
                                  e.logger();
                                }
                              },
                              isFollowing: value.statusFollowing,
                            ),
                    ],
                  );
                },
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //   child: GestureDetector(
              //     onTap: () {},
              //     child: Text(
              //       (data?.following ?? false) ? (lang?.follow ?? '') : (lang?.following ?? ''),
              //       style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
              //     ),
              //   ),
              // ),
              GestureDetector(
                // onTap: () {
                //   if (vidData?.email != SharedPreference().readStorage(SpKeys.email)) {
                //     vidNotifier.reportContent(context, vidNotifier.vidData?[index] ?? ContentData());
                //   } else {
                //     ShowBottomSheet().onShowOptionContent(
                //       context,
                //       contentData: vidData ?? ContentData(),
                //       captionTitle: hyppeVid,
                //       onDetail: false,
                //       isShare: vidData?.isShared,
                //       onUpdate: () => context.read<HomeNotifier>().onUpdate(),
                //     );
                //   }
                // },
                child: const Icon(
                  Icons.more_vert,
                  color: kHyppeTextLightPrimary,
                ),
              ),
            ],
          ),
          twentyPx,
          Stack(
            children: [
              CustomBaseCacheImage(
                memCacheWidth: 100,
                memCacheHeight: 100,
                widthPlaceHolder: 80,
                heightPlaceHolder: 80,
                imageUrl: (data?.isApsara ?? false) ? (data?.mediaThumbEndPoint ?? "") : "${data?.fullThumbPath}",
                imageBuilder: (context, imageProvider) => Container(
                  margin: margin,
                  // const EdgeInsets.symmetric(horizontal: 4.5),
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenWidth! / 1.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: _buildBody(context, SizeConfig.screenWidth),
                ),
                errorWidget: (context, url, error) {
                  'errorWidget :  $error'.logger();
                  return Container(
                    margin: margin,
                    // const EdgeInsets.symmetric(horizontal: 4.5),
                    width: _scaling,
                    height: 186,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('${AssetPath.pngPath}content-error.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _buildBody(context, SizeConfig.screenWidth),
                  );
                },
                emptyWidget: Container(
                  margin: margin,
                  // const EdgeInsets.symmetric(horizontal: 4.5),
                  width: _scaling,
                  height: 186,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('${AssetPath.pngPath}content-error.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _buildBody(context, SizeConfig.screenWidth),
                ),
              ),
            ],
          ),
          twentyPx,
          Row(
            children: [
              Consumer<LikeNotifier>(
                builder: (context, notifier, child) => Align(
                  alignment: Alignment.bottomRight,
                  child: data?.insight?.isloading ?? false
                      ? const SizedBox(
                          height: 21,
                          width: 21,
                          child: CircularProgressIndicator(
                            color: kHyppePrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : InkWell(
                          child: CustomIconWidget(
                            defaultColor: false,
                            color: (data?.insight?.isPostLiked ?? false) ? kHyppePrimary : kHyppeTextLightPrimary,
                            iconData: '${AssetPath.vectorPath}${(data?.insight?.isPostLiked ?? false) ? 'liked.svg' : 'none-like.svg'}',
                            height: 18,
                          ),
                          onTap: () {
                            if (data != null) {
                              notifier.likePost(context, data!);
                            }
                          },
                        ),
                ),
              ),
              const Padding(
                padding: const EdgeInsets.only(left: 21.0),
                child: CustomIconWidget(
                  defaultColor: false,
                  color: kHyppeTextLightPrimary,
                  iconData: '${AssetPath.vectorPath}comment2.svg',
                  height: 18,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.only(left: 21.0),
                child: CustomIconWidget(
                  defaultColor: false,
                  color: kHyppeTextLightPrimary,
                  iconData: '${AssetPath.vectorPath}share2.svg',
                  height: 18,
                ),
              ),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomIconWidget(
                    defaultColor: false,
                    color: kHyppeTextLightPrimary,
                    iconData: '${AssetPath.vectorPath}cart.svg',
                    height: 18,
                  ),
                ),
              ),
            ],
          ),
          twelvePx,
          CustomNewDescContent(
            // desc: "${data?.description}",
            username: "Username",
            desc: "${data?.description}",
            trimLines: 2,
            textAlign: TextAlign.start,
            seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
            seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "Lihat semua 200 komentar",
              style: TextStyle(fontSize: 12, color: kHyppeBurem),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return CustomNewDescContent(
                // desc: "${data?.description}",
                username: "kevinsaputra",
                desc: "Mau ikut dong!!",
                trimLines: 2,
                textAlign: TextAlign.start,
                seeLess: ' seeLess', // ${notifier2.translate.seeLess}',
                seeMore: '  Selengkapnya ', //${notifier2.translate.seeMoreContent}',
                normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
                hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
                expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "${System().readTimestamp(
                DateTime.parse(System().dateTimeRemoveT(data?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                context,
                fullCaption: true,
              )}",
              style: TextStyle(fontSize: 12, color: kHyppeBurem),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(context, width) {
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false);
    return Stack(
      children: [
        PicTopItem(data: data),
        const Positioned(
          bottom: 18,
          left: 12,
          child: CustomIconWidget(
            iconData: '${AssetPath.vectorPath}tag_people.svg',
            defaultColor: false,
            height: 20,
          ),
        ),
        const Positioned(
          bottom: 18,
          right: 12,
          child: CustomIconWidget(
            iconData: '${AssetPath.vectorPath}sound-on.svg',
            defaultColor: false,
            height: 20,
          ),
        ),
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
                    width: 200.0,
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
