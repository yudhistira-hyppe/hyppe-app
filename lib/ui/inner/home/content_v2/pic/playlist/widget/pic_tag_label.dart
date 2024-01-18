import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:provider/provider.dart';

class PicTagLabel extends StatelessWidget {
  final String icon;
  final String label;
  final double? width;
  final Function() function;
  const PicTagLabel({Key? key, required this.icon, required this.label, required this.function, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicTagLabel');
    return Consumer<PreviewVidNotifier>(builder: (_, notifier, __) {
      return GestureDetector(
        onTap: function,
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: EdgeInsets.only(right: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: kHyppeSurface.withOpacity(0.2)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                width: width,
                iconData: "${AssetPath.vectorPath + icon}.svg",
                defaultColor: false,
                // color: Colors.white,
              ),
              sixPx,
              Text(
                label.length < 20 ? label : "${label.substring(0, 20)}...",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kHyppeLightBackground),
              ),
            ],
          ),
        ),
      );
    });
  }
}
