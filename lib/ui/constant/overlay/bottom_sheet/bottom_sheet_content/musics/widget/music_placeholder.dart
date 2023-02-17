import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/musics/widget/shimmer_music_item.dart';

class MusicPlaceholder extends StatelessWidget {
  const MusicPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 17,
        itemBuilder: (context, index){
          return const ShimmerMusicItem();
    });
  }
}
