import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../../core/bloc/posts_v2/state.dart';
import '../../../../../../../core/models/collection/music/music.dart';

class LoadingMusicScreen extends StatefulWidget {
  final Music music;
  final int index;
  const LoadingMusicScreen({Key? key, required this.music, required this.index}) : super(key: key);

  @override
  State<LoadingMusicScreen> createState() => _LoadingMusicScreenState();
}

class _LoadingMusicScreenState extends State<LoadingMusicScreen> {

  @override
  void initState() {
    print('initState LoadingMusicScreen');
    super.initState();
    final notifier = context.read<SlidedPicDetailNotifier>();
    if(globalAudioPlayer != null){
      globalAudioPlayer!.stop();
      globalAudioPlayer!.dispose();
    }

    initMusic(context, widget.music, notifier);
  }

  void initMusic(BuildContext context, Music music, SlidedPicDetailNotifier notif) async{
    try {
      final apsaraId = music.apsaraMusic;
      if((apsaraId ?? '').isNotEmpty){
        print('check index hit ${widget.index} : ${notif.currentIndex}');
        if(notif.currentIndex == -1 || (notif.currentIndex == widget.index)){
          final url = await _getAdsVideoApsara(context, apsaraId!);
          if((url ?? '').isNotEmpty){
            // widget.music.apsaraMusicUrl?.playUrl = url;
            print('music is $url : ${notif.isLoadMusic}');
            notif.urlMusic = url!;
            if(notif.isLoadMusic){
              notif.isLoadMusic = false;
            }else{
              print('apakah masuk isLoading2');
              notif.isLoadMusic = true;
              Future.delayed(const Duration(milliseconds: 500), (){
                print('apakah masuk isLoading3');
                notif.isLoadMusic = false;
              });
            }

          }else{
            throw 'url music is nulls';
          }
        }else{
          Future.delayed(const Duration(milliseconds: 200), (){
            print('apakah masuk isLoading');
            if(notif.isLoadMusic){
              notif.isLoadMusic = false;
            }else{
              print('apakah masuk isLoading2');
              notif.isLoadMusic = true;
              Future.delayed(const Duration(milliseconds: 500), (){
                print('apakah masuk isLoading3');
                notif.isLoadMusic = false;
              });
            }

          });
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

  Future<String?> _getAdsVideoApsara(BuildContext context, String apsaraId) async {

    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        print('jsonMap video Apsara : $jsonMap');
        return jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CustomLoading(),
    );
  }


}
