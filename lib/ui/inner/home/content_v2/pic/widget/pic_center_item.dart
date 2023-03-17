import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_follow_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
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
                  onTapOnProfileImage: () => System().navigateToProfile(context, data?.email ?? '', isReplaced: false),
                  createdAt: '2022-02-02',
                  musicName: data?.music?.musicTitle ?? '',
                  location: data?.location ?? '',
                  isIdVerified: data?.privacy?.isIdVerified,
                ),
              ),
              Consumer<PreviewPicNotifier>(
                builder: (context, picNot, child) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      if (data?.insight?.isloadingFollow != true) {
                        picNot.followUser(context, data!, isUnFollow: data?.following, isloading: data!.insight!.isloadingFollow!);
                      }
                    },
                    child: data!.insight!.isloadingFollow!
                        ? Container(
                            height: 40,
                            width: 30,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: CustomLoading(),
                            ),
                          )
                        : Text(
                            (data?.following ?? false) ? (lang?.following ?? '') : (lang?.follow ?? ''),
                            style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                          ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (data?.email != SharedPreference().readStorage(SpKeys.email)) {
                    context.read<PreviewPicNotifier>().reportContent(context, data!);
                  } else {
                    ShowBottomSheet().onShowOptionContent(
                      context,
                      contentData: data ?? ContentData(),
                      captionTitle: hyppePic,
                      onDetail: false,
                      isShare: data?.isShared,
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
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: kHyppePrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : InkWell(
                          child: CustomIconWidget(
                            defaultColor: false,
                            color: (data?.insight?.isPostLiked ?? false) ? kHyppeRed : kHyppeTextLightPrimary,
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
              if (data?.allowComments ?? true)
                Padding(
                  padding: const EdgeInsets.only(left: 21.0),
                  child: GestureDetector(
                    onTap: () {
                      ShowBottomSheet.onShowCommentV2(context, postID: data?.postID);
                    },
                    child: const CustomIconWidget(
                      defaultColor: false,
                      color: kHyppeTextLightPrimary,
                      iconData: '${AssetPath.vectorPath}comment2.svg',
                      height: 18,
                    ),
                  ),
                ),
              if ((data?.isShared ?? false) && email != data?.email)
                Padding(
                  padding: const EdgeInsets.only(left: 21.0),
                  child: GestureDetector(
                    onTap: () {
                      context.read<PicDetailNotifier>().createdDynamicLink(context, data: data);
                    },
                    child: const CustomIconWidget(
                      defaultColor: false,
                      color: kHyppeTextLightPrimary,
                      iconData: '${AssetPath.vectorPath}share2.svg',
                      height: 18,
                    ),
                  ),
                ),
              if ((data?.saleAmount ?? 0) > 0 && email != data?.email)
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await ShowBottomSheet.onBuyContent(context, data: data);
                    },
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: CustomIconWidget(
                        defaultColor: false,
                        color: kHyppeTextLightPrimary,
                        iconData: '${AssetPath.vectorPath}cart.svg',
                        height: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          twelvePx,
          CustomNewDescContent(
            // desc: "${data?.description}",
            username: data?.username ?? '',
            desc: "${data?.description}",
            trimLines: 2,
            textAlign: TextAlign.start,
            seeLess: ' ${lang?.seeLess}', // ${notifier2.translate.seeLess}',
            seeMore: '  ${lang?.seeMoreContent}', //${notifier2.translate.seeMoreContent}',
            normStyle: const TextStyle(fontSize: 12, color: kHyppeTextLightPrimary),
            hrefStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: kHyppePrimary),
            expandStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          (data?.comment?.length ?? 0) > 2
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "Lihat semua ${data?.comment?.length} komentar",
                    style: const TextStyle(fontSize: 12, color: kHyppeBurem),
                  ),
                )
              : Container(),
          (data?.comment?.length ?? 0) > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (data?.comment?.length ?? 0) > 2 ? 2 : 1,
                    itemBuilder: (context, index) {
                      return CustomNewDescContent(
                        // desc: "${data?.description}",
                        username: data?.comment?[index].userComment?.username ?? '',
                        desc: data?.comment?[index].txtMessages ?? '',
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
                )
              : Container(),
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
        if (data?.music != null)
          Positioned(
            bottom: 18,
            right: 12,
            child: GestureDetector(
              child: CustomIconWidget(
                iconData: '${AssetPath.vectorPath}sound-on.svg',
                defaultColor: false,
                height: 20,
              ),
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
