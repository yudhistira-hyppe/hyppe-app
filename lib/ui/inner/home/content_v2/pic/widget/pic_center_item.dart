import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_desc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_newdesc_content_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/profile_component.dart';
import 'package:hyppe/ui/constant/widget/profile_landingpage.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_bottom_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';

// import 'package:hyppe/ui/inner/home/content/pic/widget/pic_top_item.dart';

class PicCenterItem extends StatelessWidget {
  final Function? onTap;
  final ContentData? data;
  final EdgeInsets? margin;

  const PicCenterItem({Key? key, this.onTap, this.data, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _scaling = (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2;
    // 'mediaThumbEndPoint : ${data?.mediaThumbEndPoint} , ${data?.mediaEndpoint}. ${data?.postID}'.logger();
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
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
                    // imageUrl: '${System().showUserPicture(vidData?.avatar?.mediaEndpoint)}',
                    imageUrl:
                        'https://cdn1-production-images-kly.akamaized.net/HVzlC2h8IkU9KlXfBqQL42n2OrE=/640x360/smart/filters:quality(75):strip_icc():format(jpeg)/kly-media-production/medias/1858174/original/068844300_1517557076-Langsing-Tanpa-Diet-ala-Raisa-Andriana-Foto-Deki-Prayoga-Digital-Imaging-Muhammad-Iqbal-Nurfajri-Bintang-com.jpg',
                    // onTapOnProfileImage: () => System().navigateToProfile(context, vidData?.email ?? '', isReplaced: false),
                    onTapOnProfileImage: () {},
                    createdAt: '2022-02-02',
                    // createdAt: '${System().readTimestamp(
                    //   DateTime.parse(System().dateTimeRemoveT(vidData?.createdAt ?? DateTime.now().toString())).millisecondsSinceEpoch,
                    //   context,
                    //   fullCaption: true,
                    // )}',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Ikuti',
                    style: TextStyle(color: kHyppePrimary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: "Lato"),
                  ),
                ),
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
            const Padding(
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "11 menit lalu",
                style: TextStyle(fontSize: 12, color: kHyppeBurem),
              ),
            ),
          ],
        ),
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
