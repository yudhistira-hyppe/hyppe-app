import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/enum.dart';
import '../../../../../../../core/models/collection/music/music_type.dart';
import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_icon_widget.dart';
import '../../../../../widget/custom_spacer.dart';
import '../../../../../widget/custom_text_widget.dart';

class CategoryMusicItem extends StatefulWidget {
  final MusicEnum myEnum;
  final MusicType type;
  final int index;
  const CategoryMusicItem(
      {Key? key, required this.myEnum, required this.type, required this.index})
      : super(key: key);

  @override
  State<CategoryMusicItem> createState() => _CategoryMusicItemState();
}

class _CategoryMusicItemState extends State<CategoryMusicItem> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return InkWell(
      onTap: () {
        notifier.selectedType = widget.type;
        notifier.selectedMusicEnum = widget.myEnum;
        notifier.selectedMusic = null;
        final myId = widget.type.id;
        if (myId != null) {
          if (widget.myEnum == MusicEnum.mood) {
            notifier.getMusicByType(context, idMood: myId);
          } else if (widget.myEnum == MusicEnum.genre) {
            notifier.getMusicByType(context, idGenre: myId);
          } else {
            notifier.getMusicByType(context, idTheme: myId);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomIconWidget(
                    defaultColor: false,
                    iconData: '${AssetPath.vectorPath}ic_music.svg',
                  ),
                ),
                twelvePx,
                CustomTextWidget(
                  textToDisplay: widget.type.name ?? '',
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}arrow_right.svg",
              defaultColor: false,
            )
          ],
        ),
      ),
    );
  }
}
