import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_icon_widget.dart';
import '../../../../../widget/custom_spacer.dart';
import '../../../../../widget/custom_text_widget.dart';

class CategoryMusicItem extends StatefulWidget {
  const CategoryMusicItem({Key? key}) : super(key: key);

  @override
  State<CategoryMusicItem> createState() => _CategoryMusicItemState();
}

class _CategoryMusicItemState extends State<CategoryMusicItem> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);
    return InkWell(
      onTap: (){
        // notifier.selectMusic(widget.music, widget.index);
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
                // Image.network(widget.music.urlThumbnail ?? '')
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage('${AssetPath.vectorPath}ic_music.svg'),
                    ),
                  ),
                ),
                twelvePx,
                const CustomTextWidget(textToDisplay: 'MyGenre', textStyle: const TextStyle(color: kHyppeTextLightPrimary, fontSize: 14, fontWeight: FontWeight.w700),),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     CustomTextWidget(textToDisplay: widget.music.title ?? '', textStyle: const TextStyle(color: kHyppeTextLightPrimary, fontSize: 14, fontWeight: FontWeight.w700),),
                //     fourPx,
                //     CustomTextWidget(textToDisplay: '${widget.music.desc} • 00:${widget.music.duration}', textStyle: const TextStyle(color: kHyppeLightSecondary, fontSize: 12, fontWeight: FontWeight.w400),)
                //   ],
                // )
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
