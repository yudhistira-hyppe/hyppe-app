import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/asset_path.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';

// import 'package:story_view/controller/story_controller.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';

class BuildButton extends StatefulWidget {
  // final StoryController? storyController;
  final AnimationController? animationController;
  final ContentData? data;
  final Function? pause;
  final Function? play;
  final Function(bool)? selectedText;
  const BuildButton({
    // this.storyController,
    required this.animationController,
    required this.data,
    this.pause,
    this.play,
    this.selectedText,
  });

  @override
  State<BuildButton> createState() => _BuildButtonState();
}

class _BuildButtonState extends State<BuildButton> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'BuildButton');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<StoriesPlaylistNotifier>(context);
    return notifier.isKeyboardActive
        ? UnconstrainedBox(
            child: GestureDetector(
              onTap: () => notifier.sendMessage(context, widget.data),
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
                onTap: () async {
                  widget.selectedText!(true);
                  // widget.pause!();
                  await context.handleActionIsGuest(() async {
                    print('--> story_page/widget/build_button.dart showMyReaction:');
                    print(widget.data!.toJson());
                    // if (widget.pause != null) {
                    //   widget.pause!();
                    // }
                    notifier.showMyReaction(
                        context,
                        mounted,
                        widget.data,
                        // widget.storyController,
                        widget.animationController,
                        widget.selectedText
                        // widget.play!,
                        );
                  });
                  // widget.play!();
                  // widget.selectedText!(false);
                },
                child: CustomIconWidget(
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}reaction.svg',
                  color: notifier.loadReaction ? kHyppeLightSecondary : kHyppeLightButtonText,
                ),
              ),
              InkWell(
                child: const CustomIconWidget(
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}share-white.svg',
                  color: kHyppeLightButtonText,
                ),
                onTap: () async {
                  if (widget.pause != null) {
                    widget.pause!();
                  }
                  await notifier.createdDynamicLink(context, widget.data);
                },
              )
            ],
          );
  }
}
