import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:provider/provider.dart';

class BuildReplayCaption extends StatelessWidget {
  final ContentData? data;
  const BuildReplayCaption({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final double _showBottomPos =
        (MediaQuery.of(context).viewInsets.bottom + SizeWidget().calculateSize(60, SizeWidget.baseHeightXD, SizeConfig.screenHeight!));

    final double _hideBottomPos = (-SizeWidget().calculateSize(100, SizeWidget.baseHeightXD, SizeConfig.screenHeight!));

    final notifier = Provider.of<StoriesPlaylistNotifier>(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      bottom: notifier.isKeyboardActive ? _showBottomPos : _hideBottomPos,
      curve: Curves.bounceOut,
      height: SizeWidget().calculateSize(83, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
      child: SizedBox(
        width: SizeConfig.screenWidth,
        height: SizeWidget().calculateSize(83, SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}private.svg",
            ),
            SizedBox(
              width: 10 * SizeConfig.scaleDiagonal,
            ),
            CustomTextWidget(
              textToDisplay: "Hanya Balas ke ${data?.username}",
              textStyle: Theme.of(context).textTheme.bodyText1?.apply(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
