import 'package:hyppe/ui/constant/entities/stories/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class Handler extends StatelessWidget {
  const Handler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        eightPx,
        const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
        sixteenPx,
        CustomTextWidget(
          textToDisplay: 'Seen by ${context.read<ViewerStoriesNotifier>().viewers}',
          textStyle: Theme.of(context).textTheme.headline6,
        ),
      ],
    );
  }
}
