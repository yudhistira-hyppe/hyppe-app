import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_thumb_image.dart';
import 'package:hyppe/ui/constant/widget/icon_ownership.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:provider/provider.dart';

class VideoThumbnail extends StatelessWidget {
  final ContentData? videoData;
  final Function fn;
  final bool onDetail;
  final bool withMargin;

  const VideoThumbnail({
    Key? key,
    this.videoData,
    required this.fn,
    required this.onDetail,
    this.withMargin = false,
  }) : super(key: key);

  static final _system = System();
  static String email = SharedPreference().readStorage(SpKeys.email);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VideoThumbnail');
    SizeConfig().init(context);
    final isHorizon = (videoData?.metadata?.height ?? 0) < (videoData?.metadata?.width ?? 0);
    final lang = context.read<TranslateNotifierV2>().translate;
    return Stack(
      children: [
        /// Thumbnail
        Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CustomBaseCacheImage(
              // cacheKey: "${pics?[index].postID}-${_networklHasErrorNotifier.value.toString()}",
              memCacheWidth: 100,
              memCacheHeight: 100,
              widthPlaceHolder: 80,
              heightPlaceHolder: 80,
              imageUrl: (videoData?.isApsara ?? false) ? (videoData?.mediaThumbEndPoint ?? '') : '${videoData?.fullThumbPath ?? ''}',
              // imageUrl: "https://mir-s3-cdn-cf.behance.net/project_modules/max_3840/8f37ff162632759.63d906f614037.jpg",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: isHorizon ? BoxFit.fill : BoxFit.contain,
                    image: imageProvider,
                  ),
                ),
              ),

              emptyWidget: GestureDetector(
                onTap: () {
                  // _networklHasErrorNotifier.value++;
                },
                child: Container(
                    decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                    width: SizeConfig.screenWidth,
                    height: 250,
                    alignment: Alignment.center,
                    child: CustomTextWidget(textToDisplay: lang.couldntLoadVideo ?? 'Error')),
              ),
              errorWidget: (context, url, error) {
                return GestureDetector(
                  onTap: () {
                    // _networklHasErrorNotifier.value++;
                  },
                  child: Container(
                      decoration: BoxDecoration(color: kHyppeNotConnect, borderRadius: BorderRadius.circular(16)),
                      width: SizeConfig.screenWidth,
                      height: 250,
                      alignment: Alignment.center,
                      child: CustomTextWidget(textToDisplay: lang.couldntLoadVideo ?? 'Error')),
                );
              },
            ),
            // CustomThumbImage(
            //   memCacheHeight: 30,
            //   memCacheWidth: 30,
            //   onTap: () {},
            //   postId: videoData?.postID,
            //   boxFit: isHorizon ? BoxFit.fill : BoxFit.contain,
            //   // imageUrl: 'https://vod.hyppe.cloud/00f120afbe2741be938a93053643c7a2/snapshots/11d8097848ff457b833e5bb0b8bfb482-00004.jpg',
            //   imageUrl: (videoData?.isApsara ?? false) ? (videoData?.mediaThumbEndPoint ?? '') : '${videoData?.fullThumbPath}',
            // ),
          ),
        ),

        /// Back Button & More Options
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // CustomBalloonWidget(
                //   child: Visibility(
                //     visible: onDetail,
                //     child: GestureDetector(
                //       onTap: () => Routing().moveBack(),
                //       child: CustomIconWidget(
                //         defaultColor: false,
                //         iconData: '${AssetPath.vectorPath}back-arrow.svg',
                //         color: kHyppeLightButtonText,
                //       ),
                //     ),
                //   ),
                // ),

                Visibility(
                  visible: (videoData?.saleAmount ?? 0) > 0,
                  child: Container(
                    margin: withMargin ? const EdgeInsets.only(top: 10, right: 10) : null,
                    padding: EdgeInsets.all(videoData?.email == SharedPreference().readStorage(SpKeys.email) ? 2.0 : 13),
                    child: const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}sale.svg",
                      defaultColor: false,
                      height: 22,
                    ),
                  ),
                ),
                // Visibility(
                //     visible: (videoData?.certified ?? false) && (videoData?.saleAmount ?? 0) == 0,
                //     child: Container(
                //         padding: const EdgeInsets.all(8),
                //         decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(4),
                //           color: Colors.black.withOpacity(0.3),
                //         ),
                //         child: const CustomIconWidget(
                //           iconData: '${AssetPath.vectorPath}ownership.svg',
                //           defaultColor: false,
                //         ))),
                // Visibility(
                //   visible: videoData?.email == SharedPreference().readStorage(SpKeys.email),
                //   child: SizedBox(
                //     width: 30,
                //     child: CustomTextButton(
                //       style: ButtonStyle(
                //         padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.only(right: 10)),
                //       ),
                //       onPressed: () => ShowBottomSheet().onShowOptionContent(
                //         context,
                //         contentData: videoData ?? ContentData(),
                //         captionTitle: hyppeVid,
                //         onDetail: onDetail,
                //         isShare: videoData?.isShared,
                //         onUpdate: () => onDetail ? context.read<VidDetailNotifier>().onUpdate() : context.read<HomeNotifier>().onUpdate(),
                //       ),
                //       child: const CustomIconWidget(
                //         defaultColor: false,
                //         iconData: '${AssetPath.vectorPath}more.svg',
                //         color: kHyppeLightButtonText,
                //       ),
                //     ),
                //   ),
                // ),
                // Visibility(
                //   visible: onDetail && videoData?.email != SharedPreference().readStorage(SpKeys.email),
                //   child: CustomTextButton(
                //     onPressed: () => ShowBottomSheet.onReportContent(
                //       context,
                //       postData: videoData,
                //       type: hyppeVid,
                //       onUpdate: () => onDetail ? context.read<VidDetailNotifier>().onUpdate() : context.read<HomeNotifier>().onUpdate(),
                //     ),
                //     child: const CustomIconWidget(
                //       defaultColor: false,
                //       iconData: '${AssetPath.vectorPath}more.svg',
                //       color: kHyppeLightButtonText,
                //     ),
                //   ),
                // ),
                Visibility(
                  visible: (videoData?.saleAmount == 0 && (videoData?.certified ?? false)),
                  child: Container(
                    margin: withMargin ? const EdgeInsets.only(top: 10, right: 10) : null,
                    padding: const EdgeInsets.all(8.0),
                    child: const IconOwnership(correct: true),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// play pause button
        // Center(
        //   child: CustomTextButton(
        //     onPressed: () => fn(),
        //     child: const CustomIconWidget(
        //       defaultColor: false,
        //       iconData: '${AssetPath.vectorPath}pause.svg',
        //       color: kHyppeLightButtonText,
        //     ),
        //   ),
        // ),

        /// Like count & Duration Video
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 20,
                  width: 20,
                ),
                // Consumer<LikeNotifier>(
                //   builder: (context, value, child) {
                //     return GestureDetector(
                //       onTap: () {
                //         Provider.of<LikeNotifier>(context, listen: false).viewLikeContent(context, videoData?.postID ?? '', 'LIKE', 'Like', videoData?.email);
                //       },
                //       child: CustomBalloonWidget(
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             const CustomIconWidget(
                //               width: 20,
                //               height: 20,
                //               defaultColor: false,
                //               iconData: '${AssetPath.vectorPath}like.svg',
                //               color: kHyppeLightButtonText,
                //             ),
                //             fourPx,
                //             CustomTextWidget(
                //               textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                //               textToDisplay: _system.formatterNumber(videoData?.insight?.likes),
                //             )
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
                CustomBalloonWidget(
                  child: CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                    textToDisplay: System().formatDuration(Duration(seconds: videoData?.metadata?.duration ?? 0).inMilliseconds),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
