import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/ui/constant/entities/like/notifier.dart';

class PicBottomItem extends StatelessWidget {
  final ContentData? data;
  final double? width;
  const PicBottomItem({Key? key, this.data, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicBottomItem');
    SizeConfig().init(context);
    return Consumer<LikeNotifier>(
      builder: (context, value, child) {
        // return CustomBalloonWidget(
        return Stack(
          children: [
            Positioned(
              bottom: 18,
              right: 90,
              child: CustomIconWidget(
                iconData: '${AssetPath.vectorPath}sound-on.svg',
                defaultColor: false,
                height: 20,
              ),
            ),
            // Container(
            //   height: 26,
            //   alignment: Alignment.center,
            //   width: width,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: const [
            //       CustomIconWidget(
            //         iconData: '${AssetPath.vectorPath}tag_people.svg',
            //         defaultColor: false,
            //         height: 20,
            //       ),
            //       CustomIconWidget(
            //         iconData: '${AssetPath.vectorPath}sound-on.svg',
            //         defaultColor: false,
            //         height: 20,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
