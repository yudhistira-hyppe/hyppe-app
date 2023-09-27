import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class SettingTile extends StatelessWidget {
  final String icon;
  final String caption;
  final Widget? trailing;
  final Function()? onTap;
  final GlobalKey? keyGLobal;
  final TooltipPosition? positionTooltip;
  final String? descriptionCas;
  final double? positionYplus;
  final int? indexTutor;

  const SettingTile({
    Key? key,
    this.onTap,
    this.trailing,
    required this.icon,
    required this.caption,
    this.keyGLobal,
    this.positionTooltip,
    this.descriptionCas,
    this.positionYplus = 0,
    this.indexTutor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SettingTile');
    final theme = Theme.of(context);
    final mn = context.read<MainNotifier>();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  defaultColor: false,
                  height: 20,
                  width: 20,
                  color: theme.iconTheme.color,
                  iconData: '${AssetPath.vectorPath}$icon',
                ),
                sixteenPx,
                Showcase(
                  key: keyGLobal ?? GlobalKey(),
                  tooltipBackgroundColor: kHyppeTextLightPrimary,
                  overlayOpacity: 0,
                  targetPadding: const EdgeInsets.all(0),
                  tooltipPosition: positionTooltip,
                  description: descriptionCas,
                  // description: lang?.localeDatetime == 'id' ? mn?.tutorialData[indexKeySell].textID ?? '' : mn?.tutorialData[indexKeySell].textEn ?? '',
                  descTextStyle: TextStyle(fontSize: 10, color: kHyppeNotConnect),
                  descriptionPadding: EdgeInsets.all(6),
                  textColor: Colors.white,
                  targetShapeBorder: const CircleBorder(),
                  positionYplus: positionYplus,
                  onToolTipClick: () {
                    context.read<TutorNotifier>().postTutor(context, mn.tutorialData[indexTutor ?? 0].key ?? '');
                    mn.tutorialData[indexTutor ?? 0].status = true;
                    ShowCaseWidget.of(context).next();
                  },
                  closeWidget: GestureDetector(
                    onTap: () {
                      try {
                        print(indexTutor);
                        context.read<TutorNotifier>().postTutor(context, mn.tutorialData[indexTutor ?? 0].key ?? '');
                        mn.tutorialData[indexTutor ?? 0].status = true;
                        ShowCaseWidget.of(context).next();
                      } catch (e) {
                        print("---===========error $e--====");
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CustomIconWidget(
                        iconData: '${AssetPath.vectorPath}close.svg',
                        defaultColor: false,
                        height: 16,
                      ),
                    ),
                  ),
                  child: CustomTextWidget(
                    textToDisplay: caption,
                    textStyle: theme.textTheme.bodyText1,
                  ),
                ),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
