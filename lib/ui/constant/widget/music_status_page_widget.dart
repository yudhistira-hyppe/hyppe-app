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
  final double vertical;
  final String? urlMusic;
  final bool isPlay;
  const MusicStatusPage({Key? key, required this.music, this.urlMusic, this.vertical = 10, this.isPlay = true}) : super(key: key);

  @override
  State<MusicStatusPage> createState() => _MusicStatusPageState();
}

class _MusicStatusPageState extends State<MusicStatusPage> with AfterFirstLayoutMixin {
  var audioPlayer = AudioPlayer();

  @override
  void initState() {
    print('initState Url: ${widget.urlMusic}');
    super.initState();
  }

  @override
  void deactivate() {
    print('deactivate MusicStatusPage');
    try {
      audioPlayer.stop();
      audioPlayer.dispose();
    } catch (e) {
      'Error MusicStatusPage : $e'.logger();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    print('dispose MusicStatusPage false');
    globalAudioPlayer = null;
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicTitle = '${widget.music.artistName} - ${widget.music.musicTitle}';
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: widget.vertical),
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
                const CustomIconWidget(
                  iconData: '${AssetPath.vectorPath}music_stroke_white.svg',
                  color: Colors.white,
                ),
                fourPx,
                musicTitle.length > 30
                    ? Container(
                        height: 30,
                        child: Container(
                            height: 30,
                            width: context.getWidth() * 0.7,
                            child: Marquee(
                              text: '$musicTitle  ',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                            )),
                      )
                    : DefaultTextStyle(
                        style: TextStyle(),
                        child: CustomTextWidget(
                          textToDisplay: musicTitle,
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                        ),
                      )
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
                decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(18))),
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
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(18))),
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

  void initMusic(BuildContext context, String urlMusic) async {
    audioPlayer = AudioPlayer();
    print('initMusic Url: $urlMusic');
    try {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      if (urlMusic.isNotEmpty) {
        globalAudioPlayer = audioPlayer;
        audioPlayer.play(UrlSource(urlMusic));
      } else {
        throw 'URL Music is empty';
      }
    } catch (e) {
      "Error Init Video $e".logger();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if ((widget.urlMusic ?? '').isNotEmpty) {
      globalAudioPlayer = audioPlayer;
      initMusic(context, widget.urlMusic!);
    } else if ((widget.music.apsaraMusicUrl?.playUrl ?? '').isNotEmpty) {
      if (widget.isPlay) {
        print('MusicStatusPage : ${widget.music.apsaraMusicUrl?.playUrl} : ${widget.urlMusic}');
        initMusic(context, widget.music.apsaraMusicUrl!.playUrl!);
      }
    }
  }
}
