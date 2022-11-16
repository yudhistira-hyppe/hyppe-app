import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/category_music_item.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../inner/upload/preview_content/notifier.dart';

class MusicTypeItem extends StatefulWidget {
  String name;
  int index;
  MusicTypeItem({Key? key, required this.name, required this.index}) : super(key: key);

  @override
  State<MusicTypeItem> createState() => _MusicTypeItemState();
}

class _MusicTypeItemState extends State<MusicTypeItem> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    final list = widget.name == notifier.language.theme ? notifier.listThemes : widget.name == notifier.language.genre ? notifier.listGenres : notifier.listMoods;
    final myEnum = widget.name == notifier.language.theme ? MusicEnum.theme : widget.name == notifier.language.genre ? MusicEnum.genre : MusicEnum.mood;
    return list.isNotEmpty ? Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  textToDisplay: widget.name,
                  textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),),
                // CustomTextButton(
                //     onPressed: (){
                //
                //     },
                //     child: CustomTextWidget(
                //       textToDisplay: notifier.language.seeAll ?? '',
                //       textStyle: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontSize: 14),))
              ],
            ),
          ),
          Column(
            children: list.map((e){

              final indexType = list.indexOf(e);
              return CategoryMusicItem(myEnum: myEnum,type: list[indexType], index: indexType);
            }).toList(),
          )
        ],
      ),
    ) : const SizedBox(height: 0,);
  }
}
