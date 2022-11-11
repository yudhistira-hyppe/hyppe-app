import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/explored_music_tab.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/music_tabs.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/popular_music_tab.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../widget/custom_icon_widget.dart';
import '../../../../widget/custom_search_bar.dart';
import '../../../../widget/custom_text_widget.dart';

class OnChooseMusicBottomSheet extends StatelessWidget {
  const OnChooseMusicBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<PreviewContentNotifier>(builder: (context, notifier, _){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          twelvePx,
          const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}handler.svg"),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: CustomSearchBar(
              hintText: notifier.language.searchMusic,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              // focusNode: notifier.focusNode1,
              // controller: notifier.searchController1,
              // onSubmitted: (v) => notifier.onSearchPost(context, value: v),
              // onPressedIcon: () => notifier.onSearchPost(context),
              onTap: (){

              },
            ),
          ),
          Container(
             child: const MusicTabsScreen()
          ),
          // SliverAppBar(
          //   pinned: true,
          //   flexibleSpace: ,
          //   automaticallyImplyLeading: false,
          //   backgroundColor: Theme.of(context).colorScheme.background,
          // ),
          Expanded(child: notifier.pageMusic == 0 ? const PopularMusicTab() : const ExploredMusicTab()),
          if(notifier.selectedMusic != null)
          Container(
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: kHyppePurple),
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10, top: 8),
            child: CustomTextButton(onPressed: (){
              print('test');
              notifier.videoMerger(notifier.selectedMusic!.url ?? '');
              notifier.showSnackBar(
                color: kHyppeDanger,
                message: "Test",
              );
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


