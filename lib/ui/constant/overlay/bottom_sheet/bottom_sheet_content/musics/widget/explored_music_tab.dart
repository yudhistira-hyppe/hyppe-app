import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/music_type_item.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_loading.dart';

class ExploredMusicTab extends StatefulWidget {
  const ExploredMusicTab({Key? key}) : super(key: key);

  @override
  State<ExploredMusicTab> createState() => _ExploredMusicTabState();
}

class _ExploredMusicTabState extends State<ExploredMusicTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    final isNoData = notifier.isNoDataTypes();

    if(!isNoData){
      return !notifier.isLoadingMusic ? notifier.listType.isNotEmpty ? ListView.builder(
        itemCount: notifier.listType.length,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 10),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemBuilder: (context, index) {
          return MusicTypeItem(group: notifier.listType[index], index: index,);
        },
      ): Center(
        child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
      ): const Center(
        child: CustomLoading(),
      );
    }else{
      return Center(
        child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
      );
    }
  }


}
