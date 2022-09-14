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
  final ContentData? vidData;
  final Function() fn;

  const ContentThumbnail({Key? key, this.vidData, required this.fn}) : super(key: key);

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // print('video gambar');
    // print('${vidData?.fullThumbPath}');

    return Stack(
      children: [
        // thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: CustomThumbImage(
            onTap: fn,
            postId: vidData?.postID,
            imageUrl: vidData!.isApsara! ? vidData!.mediaThumbEndPoint : '${vidData?.fullThumbPath}',
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
                        textToDisplay: _system.formatterNumber(vidData?.insight?.likes),
                        textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeLightButtonText),
                      )
                    ],
                  ),
                ),
                CustomBalloonWidget(
                  child: CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeLightButtonText),
                    textToDisplay: System().formatDuration(Duration(seconds: vidData?.metadata?.duration ?? 0).inMilliseconds),
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
