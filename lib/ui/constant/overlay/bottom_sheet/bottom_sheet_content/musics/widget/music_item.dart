import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../inner/upload/preview_content/notifier.dart';
import '../../../../../widget/custom_base_cache_image.dart';

class MusicItemScreen extends StatefulWidget {
  final Music music;
  final int index;
  const MusicItemScreen({Key? key, required this.music, required this.index}) : super(key: key);

  @override
  State<MusicItemScreen> createState() => _MusicItemScreenState();
}

class _MusicItemScreenState extends State<MusicItemScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<PreviewContentNotifier>(context);


    return InkWell(
      onTap: (){
        notifier.selectMusic(widget.music, widget.index);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        width: double.infinity,
        color: widget.music.isSelected ? kSkeletonHighlightColor : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image.network(widget.music.urlThumbnail ?? '')
                CustomBaseCacheImage(
                  imageUrl: widget.music.urlThumbnail,
                  imageBuilder: (_, imageProvider) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover,),
                      ),
                    );
                  },
                  errorWidget: (_, __, ___) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage('${AssetPath.vectorPath}ic_music.svg'),
                        ),
                      ),
                    );
                  },
                ),
                twelvePx,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(textToDisplay: widget.music.musicTitle ?? '', textStyle: const TextStyle(color: kHyppeTextLightPrimary, fontSize: 14, fontWeight: FontWeight.w700),),
                    fourPx,
                    CustomTextWidget(textToDisplay: '${widget.music.artistName} • 00:${widget.music.duration ?? '00'}', textStyle: const TextStyle(color: kHyppeLightSecondary, fontSize: 12, fontWeight: FontWeight.w400),)
                  ],
                )
              ],
            ),
            !widget.music.isLoad ?
            IconButton(
              focusColor: Colors.grey,
              icon: CustomIconWidget(iconData: widget.music.isPlay ? "${AssetPath.vectorPath}stop_circle.svg" : "${AssetPath.vectorPath}play_circle.svg"),
              splashRadius: 1,
              onPressed: () {
                notifier.playMusic(widget.music, widget.index);
              },
            ) :
            UnconstrainedBox(
              child: Container(
                alignment: Alignment.center,
                child: const CustomLoading(),
                width: 48,
                height: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
