import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OptionBar extends StatelessWidget {
  final String title;
  final String icon;
  final int pageIndex;

  const OptionBar({
    Key? key,
    required this.title,
    required this.icon,
    required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OptionBar');
    SizeConfig().init(context);
    return Consumer<SearchNotifier>(
      builder: (_, notifier, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconData: "${AssetPath.vectorPath}$icon.svg",
            width: 20 * SizeConfig.scaleDiagonal,
            height: 20 * SizeConfig.scaleDiagonal,
            defaultColor: false,
            // color: notifier.pageIndex == pageIndex
            //     ? Theme.of(context).tabBarTheme.labelColor
            //     : Theme.of(context).tabBarTheme.unselectedLabelColor,
          ),
          SizedBox(width: 8 * SizeConfig.scaleDiagonal),
          CustomTextWidget(
            textToDisplay: title,
            textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: notifier.pageIndex == pageIndex
                      ? Theme.of(context).tabBarTheme.labelColor
                      : Theme.of(context).tabBarTheme.unselectedLabelColor,
                  fontWeight: notifier.pageIndex == pageIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}
