import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/asset_path.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';

import 'package:story_view/controller/story_controller.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class BuildButton extends StatelessWidget {
  final StoryController storyController;
  final AnimationController? animationController;
  final ContentData? data;
  const BuildButton({
    required this.storyController,
    required this.animationController,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);
    return notifier.isKeyboardActive
        ? UnconstrainedBox(
            child: GestureDetector(
              onTap: () => notifier.sendMessage(context, data),
              child: CustomIconWidget(
                width: 31,
                height: 31,
                defaultColor: false,
                color: notifier.buttonColor,
                iconData: '${AssetPath.vectorPath}message.svg',
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  notifier.showMyReaction(context, data, storyController, animationController);
                },
                child: const CustomIconWidget(
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}reaction.svg',
                  color: kHyppeLightButtonText,
                ),
              ),
              InkWell(
                child: const CustomIconWidget(
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}share-white.svg',
                  color: kHyppeLightButtonText,
                ),
                onTap: () => notifier.createdDynamicLink(context, data, storyController: storyController),
              )
            ],
          );
  }
}
