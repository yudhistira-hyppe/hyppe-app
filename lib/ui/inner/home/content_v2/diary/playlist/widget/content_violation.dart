import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:provider/provider.dart';

class ContentViolationWidget extends StatelessWidget {
  final ContentData data;
  final String text;

  const ContentViolationWidget({Key? key, required this.data, this.text = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ContentViolationWidget');
    final translate = Provider.of<TranslateNotifierV2>(context, listen: false).translate;
    SizeConfig().init(context);
    return GestureDetector(
      onTap: () {
        if (globalAliPlayer != null) {
          globalAliPlayer?.pause();
        }
        Routing().move(Routes.appeal, argument: data);
      },
      child: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}warning-white.svg",
              defaultColor: false,
            ),
            tenPx,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: text != '' ? text : (translate.thisHyppeDiaryisSubjectToModeration ?? ''),
                  textStyle: Theme.of(context).textTheme.subtitle2?.copyWith(color: Colors.white),
                ),
                CustomTextWidget(
                  textToDisplay: translate.thisMessagecanOnlyBeSeenByYou ?? '',
                  textStyle: Theme.of(context).textTheme.overline?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}chevron_right.svg",
              defaultColor: false,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
