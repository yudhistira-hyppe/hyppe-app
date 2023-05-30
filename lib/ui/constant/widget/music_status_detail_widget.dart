import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import '../../../app.dart';
import '../../../core/constants/asset_path.dart';
import '../../../core/constants/themes/hyppe_colors.dart';
import '../../../core/models/collection/music/music.dart';
import 'custom_icon_widget.dart';
import 'custom_spacer.dart';
import 'custom_text_widget.dart';


class MusicStatusDetail extends StatefulWidget {
  final Music music;
  String? urlMusic;
  MusicStatusDetail({
    Key? key,
    required this.music,
    this.urlMusic,}) : super(key: key);

  @override
  State<MusicStatusDetail> createState() => _MusicStatusDetailState();
}

class _MusicStatusDetailState extends State<MusicStatusDetail>{
  var audioPlayer = AudioPlayer();

  @override
  void initState() {
    if(widget.music.apsaraMusic != null){
      if((widget.urlMusic ?? '').isNotEmpty){
        initMusic(context, widget.urlMusic!);
      }
    }
    super.initState();
  }

  @override
  void deactivate() {
    print('deactivate MusicStatusDetail false');
    // globalAudioPlayer = null;
    super.deactivate();
  }

  @override
  void dispose() {
    globalAudioPlayer = null;
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleMusic = '${widget.music.artistName} - ${widget.music.musicTitle}';
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 13, left: 8),
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
          titleMusic.length > 30 ?
          Expanded(
            child: CustomTextWidget(textToDisplay: '${widget.music.artistName} - ${widget.music.musicTitle}',
              textAlign: TextAlign.start,
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: kHyppeTextLightPrimary),),
          ): CustomTextWidget(textToDisplay: '${widget.music.artistName} - ${widget.music.musicTitle}',
            textAlign: TextAlign.start,
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: kHyppeTextLightPrimary),)
        ],
      ),
    );
  }

  void initMusic(BuildContext context, String urlMusic) async{
    audioPlayer = AudioPlayer();
    try {

      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      if(urlMusic.isNotEmpty){
        globalAudioPlayer = audioPlayer;
        audioPlayer.play(UrlSource(urlMusic));
      }else{
        throw 'URL Music is empty';
      }
    }catch(e){
      "Error Init Video $e".logger();
    }
  }
}

