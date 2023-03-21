import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_balloon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomUserView extends StatelessWidget {
  final ContentData? data;
  const BottomUserView({Key? key, this.data}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BottomUserView');
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
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: kHyppeBackground.withOpacity(0.5), borderRadius: BorderRadius.circular(5)),
                    child: const CustomIconWidget(
                      iconData: '${AssetPath.vectorPath}user.svg',
                      defaultColor: false,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
