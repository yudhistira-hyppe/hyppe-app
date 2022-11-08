import 'package:hyppe/core/constants/asset_path.dart';
// import 'package:hyppe/core/constants/utils.dart';
// import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/playlist/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/stories/playlist/notifier.dart';
// import 'package:hyppe/ui/inner/home/content/stories/preview/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO(Hendi Noviansyah): check if this is still needed
class OnShowOptionStory extends StatelessWidget {
  final Map<String, dynamic>? arguments;

  const OnShowOptionStory({Key? key, required this.arguments}) : super(key: key);

  static final _routing = Routing();

  Widget _tileComponent(
      {required String caption,
      required String icon,
      required bool moveBack,
      required Function(PreviewStoriesNotifier, StoriesPlaylistNotifier) onTap}) {
    return Consumer2<PreviewStoriesNotifier, StoriesPlaylistNotifier>(
      builder: (context, value, value2, child) {
        return ListTile(
          onTap: () async {
            await onTap(value, value2);
            if (moveBack) _routing.moveBack();
          },
          title: CustomTextWidget(
            textAlign: TextAlign.start,
            textToDisplay: caption,
            textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: CustomIconWidget(
            defaultColor: false,
            iconData: "${AssetPath.vectorPath}$icon",
          ),
          minLeadingWidth: 20,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
              sixteenPx,
              // CustomTextWidget(
              //   textToDisplay:
              //       '$HYPPESTORY ${context.read<StoriesPlaylistNotifier>().currentStory + 1} of ${context.read<PreviewStoriesNotifier>().myStoriesData?.totalStories}',
              //   textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _tileComponent(
                moveBack: true,
                caption: 'Copy Link',
                icon: 'copy-link.svg',
                onTap: (_, value2) {
                  // value2.linkCopied = true;
                  // try {
                  //   value2
                  //       .createdDynamicLink(context, value2.dataUserStories[value2.currentPage.toInt()], null, true)
                  //       .whenComplete(() => Future.delayed(Duration(seconds: 2), () => value2.linkCopied = false));
                  // } catch (_) {
                  //   value2.linkCopied = false;
                  // }
                },
              ),
              _tileComponent(
                moveBack: false,
                caption: 'Share to...',
                icon: 'share.svg',
                onTap: (_, value2) => value2.createdDynamicLink(context, value2.dataUserStories[value2.currentPage?.toInt() ?? 0]),
              ),
              // _tileComponent(
              //   moveBack: true,
              //   caption: 'Edit',
              //   icon: 'edit-content.svg',
              //   onTap: (value, value2) {},
              // ),
              // _tileComponent(
              //   moveBack: false,
              //   caption: 'Delete',
              //   icon: 'delete.svg',
              //   onTap: (_, value2) async {
              //     await ShowGeneralDialog.deleteContentDialog(context, 'story', () async {
              //       await value2.deleteStory(
              //         context,
              //         arguments: arguments,
              //         data: value2.dataUserStories[value2.currentPage.toInt()],
              //       );
              //     });
              //   },
              // ),
            ],
          ),
        )
      ],
    );
  }
}
