import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/ui/constant/entities/like/notifier.dart';

class PicBottomItem extends StatelessWidget {
  final ContentData? data;
  const PicBottomItem({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Consumer<LikeNotifier>(
          builder: (context, value, child) {
            return CustomBalloonWidget(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomIconWidget(
                    iconData: '${AssetPath.vectorPath}like.svg',
                    defaultColor: false,
                    color: kHyppeLightButtonText,
                  ),
                  fourPx,
                  CustomTextWidget(
                    // textToDisplay: '${data!.lCount}',
                    textToDisplay: System().formatterNumber(data?.insight?.likes ?? 0),
                    textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeLightButtonText),
                  )
                ],
              ),
            );
          },
        ),
        // Consumer<LikeNotifier>(
        //   builder: (context, notifier, child) {
        //     return CustomIconButtonWidget(
        //       padding: EdgeInsets.zero,
        //       alignment: Alignment.centerRight,
        //       iconData: '${AssetPath.vectorPath}${data!.isReacted == 0 ? 'none-like.svg' : 'liked.svg'}',
        //       onPressed: () {
        //         data!.isReacted == 0 ? notifier.showReactionList(context, data) : notifier.onLikeContent(context, data: data!);
        //       },
        //     );
        //   },
        // )
      ],
    );
  }
}
