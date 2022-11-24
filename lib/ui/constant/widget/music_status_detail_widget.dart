import 'package:flutter/material.dart';

import '../../../core/constants/asset_path.dart';
import '../../../core/constants/themes/hyppe_colors.dart';
import '../../../core/models/collection/music/music.dart';
import 'custom_icon_widget.dart';
import 'custom_spacer.dart';
import 'custom_text_widget.dart';

class MusicStatusDetail extends StatelessWidget {
  final Music music;
  const MusicStatusDetail({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8, right: 13, left: 8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: kHyppeLightInactive1
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomIconWidget(iconData: '${AssetPath.vectorPath}music_stroke_white.svg'),
          sixPx,
          CustomTextWidget(textToDisplay: '${music.artistName} - ${music.musicTitle}',
            textAlign: TextAlign.start,
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: kHyppeTextLightPrimary),)
        ],
      ),
    );
  }
}
