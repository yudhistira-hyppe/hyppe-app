import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_text_widget.dart';
import 'music_item.dart';

class PopularMusicTab extends StatefulWidget {
  bool isExplored;

  PopularMusicTab({Key? key, this.isExplored = false}) : super(key: key);

  @override
  State<PopularMusicTab> createState() => _PopularMusicTabState();
}

class _PopularMusicTabState extends State<PopularMusicTab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return !notifier.isLoadingMusic ? (!widget.isExplored ? notifier.listMusics : notifier.listExpMusics).isNotEmpty ? ListView.builder(
      itemCount: ((!widget.isExplored ? notifier.listMusics : notifier.listExpMusics)).length,
      // controller: _scrollController,
      scrollDirection: Axis.vertical,
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
        return MusicItemScreen(music: !widget.isExplored ? notifier.listMusics[index] : notifier.listExpMusics[index], index: index,);
      },
    ): Center(
      child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
    ): const Center(
      child: CustomLoading(),
    );
  }
}
