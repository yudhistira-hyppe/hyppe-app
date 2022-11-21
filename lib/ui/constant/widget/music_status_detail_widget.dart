import 'package:flutter/material.dart';

import '../../../core/constants/asset_path.dart';
import '../../../core/constants/themes/hyppe_colors.dart';
import '../../../core/models/collection/music/music.dart';
import 'custom_icon_widget.dart';
import 'custom_text_widget.dart';

class MusicStatusDetail extends StatelessWidget {
  final Music music;
  const MusicStatusDetail({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: kHyppeLightInactive1
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomIconWidget(iconData: '${AssetPath.vectorPath}music_stroke_white.svg'),
          Expanded(
            child: CustomTextWidget(textToDisplay: '${music.artistName} - ${music.musicTitle}',
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: kHyppeTextLightPrimary),),
          )
        ],
      ),
    );
  }
}
