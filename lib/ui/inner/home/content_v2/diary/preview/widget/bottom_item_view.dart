import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomItemView extends StatelessWidget {
  final ContentData? data;
  const BottomItemView({this.data});
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BottomItemView');
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
                    // textToDisplay: '${data.lCount}',
                    textToDisplay:
                        System().formatterNumber(data?.insight?.likes ?? 0),
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: kHyppeLightButtonText),
                  )
                ],
              ),
            );
          },
        ),
        // Consumer<LikeNotifier>(
        //   builder: (context, notifier, child) {
        //     return Container(
        //       width: 40,
        //       height: 25,
        //       child: CustomTextButton(
        //         style: ButtonStyle(alignment: Alignment.centerRight, padding: MaterialStateProperty.all(EdgeInsets.only(left: 0.0))),
        //         onPressed: () {
        //           data.isReacted == 0 ? notifier.showReactionList(context, data) : notifier.onLikeContent(context, data: data);
        //         },
        //         child: CustomIconWidget(
        //           iconData: '${AssetPath.vectorPath}${data.isReacted == 0 ? 'none-like.svg' : 'liked.svg'}',
        //           defaultColor: false,
        //         ),
        //       ),
        //     );
        //   },
        // )
      ],
    );
  }
}
