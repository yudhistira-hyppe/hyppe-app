import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:marquee/marquee.dart';

import '../../../app.dart';
import '../../../core/constants/asset_path.dart';
import '../../../core/models/collection/music/music.dart';
import 'after_first_layout_mixin.dart';
import 'custom_base_cache_image.dart';


class MusicStatusPage extends StatefulWidget {
  final Music music;
  String? urlMusic;
  MusicStatusPage({Key? key, required this.music, this.urlMusic}) : super(key: key);

  @override
  State<MusicStatusPage> createState() => _MusicStatusPageState();
}

class _MusicStatusPageState extends State<MusicStatusPage> with AfterFirstLayoutMixin {

  var audioPlayer = AudioPlayer();

  @override
  void initState() {

    super.initState();
  }

  @override
  void deactivate() {
    print('deactivate MusicStatusPage');
    try{
      audioPlayer.stop();
      audioPlayer.dispose();
    }catch(e){
      'Error MusicStatusPage : $e'.logger();
    }
    globalAudioPlayer = null;
    super.deactivate();
  }

  @override
  void dispose() {
    print('dispose MusicStatusPage false');
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicTitle = '${widget.music.artistName} - ${widget.music.musicTitle}';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CustomIconWidget(iconData: '${AssetPath.vectorPath}music_stroke_white.svg', color: Colors.white,),
                fourPx,
                musicTitle.length > 30 ? Container(
                  height: 30,
                  child: Container(
                    height: 30,
                    width: context.getWidth() * 0.7,
                      child: Marquee(text: '$musicTitle  ', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),)),
                ) : CustomTextWidget(textToDisplay: musicTitle,
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),)
              ],
            ),
          ),
          CustomBaseCacheImage(
            imageUrl: widget.music.apsaraThumnailUrl ?? '',
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
                decoration: const BoxDecoration(
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
            emptyWidget: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18))
              ),
              child: const CustomIconWidget(
                width: 36,
                height: 36,
                defaultColor: false,
                iconData: '${AssetPath.vectorPath}ic_music.svg',
              ),
            ),
          )
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

  @override
  void afterFirstLayout(BuildContext context) {
    print('MusicStatusPage : ${widget.urlMusic}');
    if((widget.urlMusic ?? '').isNotEmpty){
      initMusic(context, widget.urlMusic!);
    }else if((widget.music.apsaraMusicUrl?.playUrl ?? '').isNotEmpty){
      print('MusicStatusPage : ${widget.music.apsaraMusicUrl?.playUrl}');
      initMusic(context, widget.music.apsaraMusicUrl!.playUrl!);
    }
  }
}
