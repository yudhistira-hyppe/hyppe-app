import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_ownership.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/widget/pic_thumbnail_report.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_thumb_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';

class PicDetailSlider extends StatefulWidget {
  final ContentData? picData;
  final bool onDetail;
  const PicDetailSlider({
    Key? key,
    this.picData,
    this.onDetail = true,
  }) : super(key: key);

  @override
  State<PicDetailSlider> createState() => _PicDetailSliderState();
}

class _PicDetailSliderState extends State<PicDetailSlider> {
  static final _system = System();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicDetailSlider');
    SizeConfig().init(context);
    final notifier = Provider.of<PicDetailNotifier>(context, listen: false);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          /// Thumbnail
          PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 1,
            onPageChanged: print,
            itemBuilder: (context, index) => InkWell(
              child: Center(
                child: (widget.picData?.reportedStatus == "BLURRED")
                    ? PichTumbnailReport(pictData: widget.picData)
                    : Builder(builder: (context) {
                        final imageUrl = (widget.picData?.isApsara ?? false)
                            ? widget.picData?.mediaThumbUri
                            : widget.picData?.fullThumbPath;
                        final isLoad = notifier.loadPic;
                        if (isLoad) {
                          return const CustomLoading();
                        } else {
                          return CustomThumbImage(
                            boxFit: BoxFit.cover,
                            imageUrl: imageUrl,
                          );
                        }
                      }),
              ),
              onTap: () {
                notifier.navigateToDetailPic(widget.picData);
              },
              onDoubleTap: () {
                final _likeNotifier = context.read<LikeNotifier>();
                final data = widget.picData;
                if (data != null) {
                  _likeNotifier.likePost(context, data);
                }
              },
              // onTap: () => notifier.navigateToSlidedDetailPic(context, index),
            ),
          ),

          /// Back Button & More Options
          ///
          (widget.picData?.saleAmount ?? 0) > 0
              ? const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}sale.svg",
                      defaultColor: false,
                      height: 22,
                    ),
                  ),
                )
              : const SizedBox(),

          (widget.picData?.saleAmount == 0) &&
                  (widget.picData?.certified ?? false)
              ? const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: IconOwnership(correct: true),
                  ),
                )
              : const SizedBox(),

          // Align(
          //   alignment: Alignment.topRight,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Visibility(
          //           visible: onDetail,
          //           child: CustomTextButton(
          //             onPressed: () => notifier.onPop(),
          //             child: const DecoratedIconWidget(
          //               Icons.arrow_back_ios,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //         picData?.email != SharedPreference().readStorage(SpKeys.email) && (picData?.reportedStatus == "BLURRED")
          //             ? SizedBox()
          //             : Row(
          //                 children: [
          //                   (picData?.saleAmount ?? 0) > 0
          //                       ? const Padding(
          //                           padding: EdgeInsets.all(2.0),
          //                           child: CustomIconWidget(
          //                             iconData: "${AssetPath.vectorPath}sale.svg",
          //                             defaultColor: false,
          //                           ),
          //                         )
          //                       : const SizedBox(),
          //                   picData?.email != SharedPreference().readStorage(SpKeys.email)
          //                       ? SizedBox(
          //                           width: 50,
          //                           child: CustomTextButton(
          //                             onPressed: () => ShowBottomSheet.onReportContent(
          //                               context,
          //                               postData: picData,
          //                               type: hyppePic,
          //                               adsData: null,
          //                               onUpdate: () => notifier.onUpdate(),
          //                             ),
          //                             child: const CustomIconWidget(
          //                               defaultColor: false,
          //                               iconData: '${AssetPath.vectorPath}more.svg',
          //                               color: kHyppeLightButtonText,
          //                             ),
          //                           ),
          //                         )
          //                       : const SizedBox(),
          //                   picData?.email == SharedPreference().readStorage(SpKeys.email)
          //                       ? SizedBox(
          //                           width: 50,
          //                           child: CustomTextButton(
          //                             onPressed: () async {
          //                               if (globalAudioPlayer != null) {
          //                                 globalAudioPlayer!.pause();
          //                               }
          //                               await ShowBottomSheet().onShowOptionContent(
          //                                 context,
          //                                 onDetail: onDetail,
          //                                 contentData: picData ?? ContentData(),
          //                                 captionTitle: hyppePic,
          //                                 onUpdate: () => notifier.onUpdate(),
          //                                 isShare: picData?.isShared,
          //                               );
          //                               if (globalAudioPlayer != null) {
          //                                 globalAudioPlayer!.seek(Duration.zero);
          //                                 globalAudioPlayer!.resume();
          //                               }
          //                             },
          //                             child: const CustomIconWidget(
          //                               defaultColor: false,
          //                               iconData: '${AssetPath.vectorPath}more.svg',
          //                               color: kHyppeLightButtonText,
          //                             ),
          //                           ),
          //                         )
          //                       : const SizedBox(),
          //                   Visibility(
          //                     visible: (picData?.saleAmount == 0 && (picData?.certified ?? false)),
          //                     child: const Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: IconOwnership(correct: true),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //       ],
          //     ),
          //   ),
          // ),

          widget.picData?.email !=
                      SharedPreference().readStorage(SpKeys.email) &&
                  (widget.picData?.reportedStatus == "BLURRED")
              ? Container()
              : Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0)
                        .copyWith(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<LikeNotifier>(
                          builder: (context, value, child) => GestureDetector(
                            onTap: () {
                              Provider.of<LikeNotifier>(context, listen: false)
                                  .viewLikeContent(
                                      context,
                                      widget.picData!.postID,
                                      'LIKE',
                                      'Like',
                                      widget.picData?.email);
                            },
                            child: CustomBalloonWidget(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CustomIconWidget(
                                    width: 20,
                                    height: 20,
                                    defaultColor: false,
                                    iconData: '${AssetPath.vectorPath}like.svg',
                                    color: kHyppeLightButtonText,
                                  ),
                                  fourPx,
                                  CustomTextWidget(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                            color: kHyppeLightButtonText),
                                    // textToDisplay: _system.formatterNumber(value.data?.insight?.likes),
                                    textToDisplay: _system.formatterNumber(
                                        widget.picData?.insight?.likes),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
