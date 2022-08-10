import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:provider/provider.dart';

class PicTagLabel extends StatelessWidget {
  String icon;
  String label;
  final Function() function;
  PicTagLabel({Key? key, required this.icon, required this.label, required this.function}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewVidNotifier>(builder: (_, notifier, __) {
      return GestureDetector(
        onTap: function,
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: EdgeInsets.only(right: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).colorScheme.secondary),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                width: 18,
                iconData: "${AssetPath.vectorPath + icon}.svg",
                defaultColor: false,
              ),
              sixPx,
              Text(
                label.length < 20 ? label : "${label.substring(0, 20)}...",
                style: Theme.of(context).textTheme.bodyText1!.copyWith(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
