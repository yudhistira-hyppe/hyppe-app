import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../../core/services/shared_preference.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../widget/custom_gesture.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/custom_text_widget.dart';
import 'on_live_stream_status.dart';

class OnWatcherStatus extends StatefulWidget {
  const OnWatcherStatus({super.key});

  @override
  State<OnWatcherStatus> createState() => _OnWatcherStatusState();
}

class _OnWatcherStatusState extends State<OnWatcherStatus> {
  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    final isIndo = SharedPreference().readStorage(SpKeys.isoCode) == 'id';
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      decoration: BoxDecoration(
        color: context.getColorScheme().background,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          sixteenPx,
          const ItemAccount(
            urlImage:
                'https://storage.googleapis.com/pai-images/52723c8072804e4493c246ca8aef68a1.jpeg',
            name: 'Natalia Jessica',
            username: 'natalia.jessica',
            isHost: false,
          ),
          twentyPx,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WatcherStatusItem(value: "100", title: language.post ?? '',),
                WatcherStatusItem(value: "100", title: language.follower ?? '',),
                WatcherStatusItem(value: "100", title: language.following ?? '',),
              ],
            ),
          ),
          sixteenPx,
          CustomGesture(
            margin: EdgeInsets.zero,
            onTap: () {

            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.getColorScheme().primary.withOpacity(0.9)),
              alignment: Alignment.center,
              child: CustomTextWidget(
                textToDisplay: language.follow ?? '',
                textAlign: TextAlign.center,
                textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WatcherStatusItem extends StatelessWidget {
  final String value;
  final String title;
  const WatcherStatusItem({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomTextWidget(
          textToDisplay: value,
          textStyle: context
              .getTextTheme()
              .bodyText1
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        fourPx,
        CustomTextWidget(
          textToDisplay: title,
          textStyle: context
              .getTextTheme()
              .bodyText2
              ?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
        ),
      ],
    );
  }
}

