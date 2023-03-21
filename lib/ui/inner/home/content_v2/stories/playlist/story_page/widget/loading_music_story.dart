import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../app.dart';
import '../../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../../constant/widget/custom_loading.dart';
import '../../notifier.dart';

class LoadingMusicStory extends StatefulWidget {
  final Music apsaraMusic;
  final int index;
  final int current;
  const LoadingMusicStory({Key? key, required this.index, required this.current, required this.apsaraMusic}) : super(key: key);

  @override
  State<LoadingMusicStory> createState() => _LoadingMusicStoryState();
}

class _LoadingMusicStoryState extends State<LoadingMusicStory> with AfterFirstLayoutMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 20,
      height: 20,
      child: const CustomLoading(),
    );
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LoadingMusicStory');
    super.initState();
    if(globalAudioPlayer != null){
      disposeGlobalAudio();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<StoriesPlaylistNotifier>();
    notifier.urlMusic?.playUrl = '';
    initMusic(context, widget.apsaraMusic, notifier);
  }

  void initMusic(BuildContext context, Music music, StoriesPlaylistNotifier notif) async{
    try {
      final apsaraId = music.apsaraMusic;
      if((apsaraId ?? '').isNotEmpty){
        print('check index hit (${widget.index} : ${notif.currentIndex}) and (${widget.current} : ${notif.currentStory})');
        if((notif.currentIndex == -1 && notif.currentStory == -1) || (notif.currentIndex == widget.index && notif.currentStory == widget.current)){
          final url = await notif.getMusicApsara(context, apsaraId!);
          if(url != null){
            // widget.music.apsaraMusicUrl?.playUrl = url;
            print('music is $url : ${notif.isLoadMusic}');
            notif.urlMusic = url;
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
      "Error Init Music $e".logger();
      Future.delayed(const Duration(milliseconds: 100), (){
        notif.isLoadMusic = false;
      });
    }
  }
}
