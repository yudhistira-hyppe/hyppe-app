import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/category_music_item.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/music/music_type.dart';
import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_text_button.dart';

class MusicTypeItem extends StatefulWidget {
  MusicGroupType group;
  int index;
  MusicTypeItem({Key? key, required this.group, required this.index}) : super(key: key);

  @override
  State<MusicTypeItem> createState() => _MusicTypeItemState();
}

class _MusicTypeItemState extends State<MusicTypeItem> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    final list = widget.group.group == notifier.language.theme ? notifier.listThemes : widget.group.group == notifier.language.genre ? notifier.listGenres : notifier.listMoods;
    List<MusicType> sortList = [];
    if(list.isNotEmpty){
      if(list.length >= 3){
        sortList = [list[0], list[1], list[2]];
      }else if(list.length >= 2){
        sortList = [list[0], list[1]];
      }else{
        sortList = [list[0]];
      }
    }
    final myEnum = widget.group.group == notifier.language.theme ? MusicEnum.theme : widget.group.group == notifier.language.genre ? MusicEnum.genre : MusicEnum.mood;
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
                  textToDisplay: widget.group.group,
                  textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),),
                if(list.length > 3)
                CustomTextButton(
                    onPressed: (){
                      notifier.setMusicGroupState(widget.index, !widget.group.isSeeAll);
                    },
                    child: CustomTextWidget(
                      textToDisplay: !widget.group.isSeeAll ? notifier.language.seeAll ?? 'See all' : notifier.language.seeSome ?? 'See some',
                      textStyle: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontSize: 14),))
              ],
            ),
          ),
          Column(
            children: (!widget.group.isSeeAll ? sortList : list).map((e){

              final indexType = (!widget.group.isSeeAll ? sortList : list).indexOf(e);
              return CategoryMusicItem(myEnum: myEnum, type: list[indexType], index: indexType);
            }).toList(),
          )
        ],
      ),
    ) : const SizedBox(height: 0,);
  }
}
