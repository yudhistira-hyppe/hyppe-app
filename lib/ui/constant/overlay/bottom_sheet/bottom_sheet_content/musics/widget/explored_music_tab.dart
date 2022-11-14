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
    return !notifier.isLoadingMusic ? notifier.listType.isNotEmpty ? ListView.builder(
      itemCount: notifier.listType.length,
      // controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 10),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // separatorBuilder: (context, index) =>
      //     const Divider(
      //   thickness: 0.95,
      //   color: Color(0xfffffffff),
      // ),
      itemBuilder: (context, index) {
        // if (index == notifier.commentData?.length && notifier.hasNext) {
        //   return const CustomLoading();
        // }
        //
        // final comments = notifier.commentData?[index];
        //
        // return Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
        //   child: CommentListTile(
        //     data: comments,
        //     fromFront: widget.fromFront,
        //   ),
        // );
        return MusicTypeItem(name: notifier.listType[index], index: index,);
      },
    ): Center(
      child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
    ): const Center(
    child: CustomLoading(),
    );
  }


}
