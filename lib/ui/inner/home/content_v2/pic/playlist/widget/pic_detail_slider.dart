import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/decorated_icon_widget.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_thumb_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/core/constants/utils.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/notifier.dart';

import '../slide/notifier.dart';

class PicDetailSlider extends StatelessWidget {
  final ContentData? picData;
  final bool onDetail;
  static final _system = System();

  const PicDetailSlider({
    Key? key,
    this.picData,
    this.onDetail = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final notifier = Provider.of<PicDetailNotifier>(context, listen: false);
    return Consumer<PicDetailNotifier>(
      builder: (_, notifier, __) => AspectRatio(
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
                  child: CustomThumbImage(
                    boxFit: BoxFit.cover,
                    imageUrl: picData!.isApsara! ? picData?.mediaThumbUri : picData?.fullThumbPath,
                  ),
                ),
                onTap: () => notifier.navigateToDetailPic(picData),
                // onTap: () => notifier.navigateToSlidedDetailPic(context, index),
              ),
            ),

            /// Back Button & More Options
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: onDetail,
                      child: CustomTextButton(
                        onPressed: () => notifier.onPop(),
                        child: const DecoratedIconWidget(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        picData?.email != SharedPreference().readStorage(SpKeys.email)
                            ? CustomTextButton(
                                onPressed: () => ShowBottomSheet.onReportContent(context),
                                child: const CustomIconWidget(
                                  defaultColor: false,
                                  iconData: '${AssetPath.vectorPath}more.svg',
                                  color: kHyppeLightButtonText,
                                ),
                              )
                            : SizedBox(),
                        picData?.email == SharedPreference().readStorage(SpKeys.email)
                            ? CustomTextButton(
                                onPressed: () => ShowBottomSheet.onShowOptionContent(
                                  context,
                                  onDetail: onDetail,
                                  contentData: picData!,
                                  captionTitle: hyppePic,
                                  onUpdate: () => notifier.onUpdate(),
                                ),
                                child: const CustomIconWidget(
                                  defaultColor: false,
                                  iconData: '${AssetPath.vectorPath}more.svg',
                                  color: kHyppeLightButtonText,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Provider.of<LikeNotifier>(context, listen: false).viewLikeContent(context, picData!.postID, 'LIKE', 'Like', picData?.email);
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
                              textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
                              // textToDisplay: _system.formatterNumber(value.data?.insight?.likes),
                              textToDisplay: "${notifier.data?.insight?.likes}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
