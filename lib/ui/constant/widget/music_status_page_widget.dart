import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../core/constants/asset_path.dart';
import '../../../core/models/collection/music/music.dart';
import '../../../core/services/system.dart';
import 'custom_profile_image.dart';

class MusicStatusPage extends StatelessWidget {
  final Music music;
  const MusicStatusPage({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CustomIconWidget(iconData: '${AssetPath.vectorPath}music_stroke_white.svg'),
              CustomTextWidget(textToDisplay: '${music.artistName} - ${music.musicTitle}',
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),)
            ],
          ),
          CustomProfileImage(
            width: 26,
            height: 26,
            following: true,
            imageUrl: System().showUserPicture(music.apsaraThumnailUrl) ?? '',
          )
        ],
      ),
    );
  }
}
