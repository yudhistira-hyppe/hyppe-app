import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
// import 'package:provider/provider.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/like/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
// import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
// import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';

import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:provider/provider.dart';
import 'package:story_view/controller/story_controller.dart';

class ViewerStoriesButton extends StatelessWidget {
  final int? currentStory;
  final ContentData? data;
  final StoryController? storyController;
  final Function? pause;
  const ViewerStoriesButton({
    Key? key,
    required this.data,
    required this.currentStory,
    this.storyController,
    this.pause,
  }) : super(key: key);

  static final _system = System();

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ViewerStoriesButton');
    final theme = Theme.of(context);
    final _language = context.watch<TranslateNotifierV2>().translate;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: CustomElevatedButton(
            width: context.getWidth() / 2,
            height: 30,
            function: () {
              // storyController.pause();
              if(pause != null){
                pause!();
              }

              Provider.of<LikeNotifier>(context, listen: false).viewLikeContent(context, data?.postID, 'VIEW', 'Viewer', data?.email, storyController: storyController);
              // context.read<StoriesPlaylistNotifier>().forceStop = true;
              // ShowBottomSheet.onShowViewers(context, storyID: data?.story[currentStory].storyID);
            },
            buttonStyle: theme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: MaterialStateProperty.all(
                Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomIconWidget(
                  defaultColor: false,
                  iconData: "${AssetPath.vectorPath}stories-viewer.svg",
                  color: kHyppeLightButtonText,
                ),
                eightPx,
                CustomTextWidget(
                  textToDisplay: '${_language.seenBy} ${_system.formatterNumber(data?.insight?.views ?? 0)}',
                  textStyle: theme.textTheme.bodyText1?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: kHyppeLightButtonText,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
