import 'package:flutter/material.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/widget/custom_thumb_image.dart';

class ContentThumbnail extends StatelessWidget {
  final ContentData? picData;
  final Function() fn;

  const ContentThumbnail({Key? key, this.picData, required this.fn}) : super(key: key);

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Stack(
      children: [
        // thumbnail
        PageView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 1,
          onPageChanged: print,
          itemBuilder: (context, index) => InkWell(
            onTap: fn,
            child: Center(
              child: CustomThumbImage(
                boxFit: BoxFit.cover,
                imageUrl: (picData?.isApsara ?? false) ? picData?.mediaThumbEndPoint : '${picData?.fullThumbPath}',
              ),
            ),
          ),
        ),

        // bottom left
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBalloonWidget(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomIconWidget(
                        defaultColor: false,
                        color: kHyppeLightButtonText,
                        iconData: '${AssetPath.vectorPath}like.svg',
                      ),
                      fourPx,
                      CustomTextWidget(
                        textToDisplay: _system.formatterNumber(picData?.insight?.likes),
                        textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                      )
                    ],
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
