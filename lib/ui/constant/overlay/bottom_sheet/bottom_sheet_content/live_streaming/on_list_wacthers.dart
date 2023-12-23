import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/live_stream/viewers_live_model.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_gesture.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../initial/hyppe/translate_v2.dart';
import '../../../../../../ux/routing.dart';
import '../../../../widget/custom_profile_image.dart';
import '../../../../widget/custom_spacer.dart';
import '../../../../widget/icon_button_widget.dart';
import '../../show_bottom_sheet.dart';

class OnListWatchers extends StatefulWidget {
  const OnListWatchers({super.key});

  @override
  State<OnListWatchers> createState() => _OnListWatchersState();
}

class _OnListWatchersState extends State<OnListWatchers> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var streampro = Provider.of<StreamerNotifier>(context, listen: false);
      streampro.getViewer(context, mounted, end: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, notifier, __) => SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 64,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      child: CustomIconButtonWidget(
                        height: 30,
                        width: 30,
                        onPressed: () {
                          Routing().moveBack();
                        },
                        color: Colors.black,
                        defaultColor: false,
                        iconData: "${AssetPath.vectorPath}back-arrow.svg",
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: CustomTextWidget(
                      textToDisplay: language.viewerList ?? 'List Penonton',
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: notifier.dataViewers.length,
                  itemBuilder: (context, index) {
                    final watcher = notifier.dataViewers[index];
                    return watcherItem(watcher, index, language);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget watcherItem(ViewersLiveModel watcher, int index, LocalizationModelV2 language) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextWidget(
            textToDisplay: '${index + 1}',
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          sixteenPx,
          Flexible(
            child: InkWell(
              onTap: () => ShowBottomSheet.onWatcherStatus(context, watcher.email ?? '', watcher.sId ?? ''),
              child: Row(
                children: [
                  CustomProfileImage(
                    width: 36,
                    height: 36,
                    following: true,
                    imageUrl: System().showUserPicture(watcher.avatar?.mediaEndpoint),
                  ),
                  twelvePx,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: watcher.username ?? '',
                          textStyle: context.getTextTheme().bodyText2?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        fourPx,
                        CustomTextWidget(
                          textAlign: TextAlign.left,
                          textToDisplay: watcher.fullName ?? '',
                          textStyle: context.getTextTheme().caption?.copyWith(fontWeight: FontWeight.w400, color: kHyppeBurem),
                        ),
                      ],
                    ),
                  ),
                  tenPx
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
