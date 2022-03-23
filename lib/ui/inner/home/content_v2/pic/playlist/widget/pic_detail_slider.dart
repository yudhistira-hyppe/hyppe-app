import 'package:flutter/material.dart';
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

class PicDetailSlider extends StatelessWidget {
  final ContentData? picData;
  final bool onDetail;

  const PicDetailSlider({
    Key? key,
    this.picData,
    this.onDetail = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                child: CustomThumbImage(
                  boxFit: BoxFit.cover,
                  imageUrl: picData?.fullThumbPath,
                ),
              ),
              onTap: () => notifier.navigateToDetailPic(picData),
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
                        shadows: [
                          BoxShadow(
                            blurRadius: 12.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: picData?.email == SharedPreference().readStorage(SpKeys.email),
                    child: CustomTextButton(
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
