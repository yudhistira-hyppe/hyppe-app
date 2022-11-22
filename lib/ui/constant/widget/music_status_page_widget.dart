import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../core/constants/asset_path.dart';
import '../../../core/models/collection/music/music.dart';
import 'custom_base_cache_image.dart';

class MusicStatusPage extends StatelessWidget {
  final Music music;
  const MusicStatusPage({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CustomIconWidget(iconData: '${AssetPath.vectorPath}music_stroke_white.svg', color: Colors.white,),
              fourPx,
              CustomTextWidget(textToDisplay: '${music.artistName} - ${music.musicTitle}',
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),)
            ],
          ),
          CustomBaseCacheImage(
            imageUrl: music.apsaraThumnailUrl ?? '',
            imageBuilder: (_, imageProvider) {
              print('MusicStatusPage success');
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
                ),
              );
            },
            errorWidget: (_, __, ___) {

              print('MusicStatusPage error');
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18))
                ),
                child: const CustomIconWidget(
                  width: 36,
                  height: 36,
                  defaultColor: false,
                  iconData: '${AssetPath.vectorPath}ic_music.svg',
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
