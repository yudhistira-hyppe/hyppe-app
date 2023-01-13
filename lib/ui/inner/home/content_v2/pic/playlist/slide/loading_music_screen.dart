import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../constant/widget/custom_base_cache_image.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';
import '../notifier.dart';

class LoadingMusicScreen extends StatefulWidget {
  final Music music;
  final int index;
  const LoadingMusicScreen({Key? key, required this.music, required this.index}) : super(key: key);

  @override
  State<LoadingMusicScreen> createState() => _LoadingMusicScreenState();
}

class _LoadingMusicScreenState extends State<LoadingMusicScreen> with AfterFirstLayoutMixin {

  @override
  void initState() {
    print('initState LoadingMusicScreen');
    super.initState();
    if(globalAudioPlayer != null){
      disposeGlobalAudio();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SlidedPicDetailNotifier>();
    initMusic(context, widget.music, notifier);
  }

  void initMusic(BuildContext context, Music music, SlidedPicDetailNotifier notif) async{
    try {
      final apsaraId = music.apsaraMusic;
      final detailNotifier = context.read<PicDetailNotifier>();
      notif.urlMusic = '';
      detailNotifier.urlMusic = '';
      if((apsaraId ?? '').isNotEmpty){
        print('check index hit ${widget.index} : ${notif.currentIndex} and my mainIndex = ${notif.mainIndex}');
        if((notif.currentIndex == -1 || (notif.currentIndex == widget.index)) && notif.mainIndex == 0){
          final url = await notif.getAdsVideoApsara(context, apsaraId!);
          if((url ?? '').isNotEmpty){
            // widget.music.apsaraMusicUrl?.playUrl = url;
            print('music is $url : ${notif.isLoadMusic}');
            notif.urlMusic = url!;
            if(notif.isLoadMusic){
              notif.isLoadMusic = false;
            }else{
              print('apakah masuk isLoading6');
              notif.isLoadMusic = true;
              Future.delayed(const Duration(milliseconds: 500), (){
                print('apakah masuk isLoading7');
                notif.isLoadMusic = false;
              });
            }

          }else{
            throw 'url music is nulls';
          }
        }else{
          if(!notif.hitApiMusic){
            if(notif.isLoadMusic){
              notif.isLoadMusic = false;
              Future.delayed(const Duration(milliseconds: 500), (){
                if(!notif.hitApiMusic){
                  print('apakah masuk isLoading2');
                  notif.isLoadMusic = true;
                  Future.delayed(const Duration(milliseconds: 500), (){
                    if(!notif.hitApiMusic){
                      print('apakah masuk isLoading3');
                      notif.isLoadMusic = false;
                    }
                  });
                }

              });
            }else{
              print('apakah masuk isLoading4');
              notif.isLoadMusic = true;
              Future.delayed(const Duration(milliseconds: 500), (){
                if(!notif.hitApiMusic){
                  print('apakah masuk isLoading5');
                  notif.isLoadMusic = false;
                }

              });
            }
          }

          // throw 'cannot hit the apsara video';
        }
      }else{
        throw 'apsaramusic is empty';
      }
    }catch(e){
      "Error Init Video $e".logger();
      Future.delayed(const Duration(milliseconds: 100), (){
        notif.isLoadMusic = false;
      });
    }
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
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CustomLoading(),
                ),
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




}
