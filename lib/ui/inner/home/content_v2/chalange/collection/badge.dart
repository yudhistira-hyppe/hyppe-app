import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/offline_mode.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:provider/provider.dart';

class BadgeWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final double? height;
  const BadgeWidget({
    Key? key,
    this.scrollController,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfProfileNotifier>(builder: (_, notifier, __) {
      FirebaseCrashlytics.instance.setCustomKey('layout', 'BadgeWidget');

      return GridView.builder(
        itemCount: 10,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 109 / 135,
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFEAEAEA)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: CustomProfileImage(
                    following: true,
                    forStory: false,
                    width: 40,
                    height: 40,
                    imageUrl: "",
                  ),
                ),
                Divider(color: Color(0xFFEAEAEA), thickness: 1),
                sixPx,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    'Most Actived assds asdfsf',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3E3E3E),
                      fontSize: 10,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                sixPx,
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: ShapeDecoration(
                    color: Color(0xFFE8E8E8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Berlaku Hingga 22 Des 2023',
                        style: TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 6,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    });
  }
}
