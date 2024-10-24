import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/explored_music_tab.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/explorer_musics_screen.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/music_placeholder.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/music_tabs.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/popular_music_tab.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_search_bar.dart';
import '../../../../widget/custom_text_widget.dart';
import '../../../../widget/icon_button_widget.dart';

class OnChooseMusicBottomSheet extends StatefulWidget {
  final bool isPic;
  final bool isInit;
  const OnChooseMusicBottomSheet({Key? key, required this.isPic, this.isInit = true}) : super(key: key);

  @override
  State<OnChooseMusicBottomSheet> createState() => _OnChooseMusicBottomSheetState();
}

class _OnChooseMusicBottomSheetState extends State<OnChooseMusicBottomSheet> {
  @override
  void initState() {
    final notifier = context.read<PreviewContentNotifier>();
    Future.delayed(Duration.zero, () async {
      notifier.isLoadingMusic = true;
      await notifier.initListMusics(context);
    });
    super.initState();
  }

  @override
  void deactivate() {
    'deactivate OnChooseMusicBottomSheet'.logger();
    final notifier = context.read<PreviewContentNotifier>();
    notifier.disposeMusic();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<PreviewContentNotifier>(builder: (context, notifier, _) {
      final showListExp = notifier.selectedType != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          twelvePx,
          const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: CustomSearchBar(
              hintText: notifier.language.searchMusic,
              contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
              focusNode: notifier.focusNode,
              controller: notifier.searchController,
              onChanged: (value) {
                notifier.onChangeSearchMusic(context, value);
              },
              onTap: () {},
            ),
          ),
          !showListExp
              ? const MusicTabsScreen()
              : Container(
                  margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 10),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomIconButtonWidget(
                        onPressed: () {
                          notifier.selectedType = null;
                          notifier.selectedMusicEnum = null;
                        },
                        color: Colors.black,
                        iconData: '${AssetPath.vectorPath}back-arrow.svg',
                        padding: const EdgeInsets.only(right: 16, left: 16),
                      ),
                      sixteenPx,
                      Expanded(
                          child: CustomTextWidget(
                        textAlign: TextAlign.left,
                        textToDisplay: notifier.selectedType?.name ?? '',
                        textStyle: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                      ))
                    ],
                  ),
                ),
          Expanded(
              child: !notifier.isLoadingMusic
                  ? notifier.pageMusic == 0
                      ? const PopularMusicTab()
                      : !showListExp
                          ? const ExploredMusicTab()
                          : const ExplorerMusicsScreen()
                  : const MusicPlaceholder()),
          if (notifier.selectedMusic != null)
            Container(
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kHyppePrimary),
              width: double.infinity,
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 8),
              child: CustomTextButton(
                  onPressed: () async {
                    final uploadNotifier = context.read<PreUploadContentNotifier>();
                    print('test');
                    // notifier.isLoadVideo = true;
                    await notifier.audioPlayer.stop();
                    if (widget.isPic) {
                      // notifier.isLoadVideo = true;
                      if (!widget.isInit) {
                        notifier.fixSelectedMusic = notifier.selectedMusic;
                      }
                      print('isLoadVideo : ${notifier.isLoadVideo}');
                      uploadNotifier.musicSelected = notifier.selectedMusic;
                      notifier.selectedMusic = null;
                      notifier.selectedType = null;
                      notifier.forceResetPlayer(true);
                      notifier.searchController.text = '';
                    } else {
                      await notifier.videoMerger(context, notifier.selectedMusic!.apsaraMusicUrl?.playUrl ?? '', isInit: widget.isInit);
                      notifier.fixSelectedMusic = notifier.selectedMusic;
                      uploadNotifier.musicSelected = notifier.selectedMusic;
                      notifier.selectedMusic = null;
                      notifier.selectedType = null;
                      notifier.forceResetPlayer(true);
                      notifier.searchController.text = '';
                    }

                    Navigator.pop(context);
                  },
                  child: CustomTextWidget(
                    textToDisplay: notifier.language.select ?? 'select',
                    textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  )),
            )
        ],
      );
    });
  }
}
