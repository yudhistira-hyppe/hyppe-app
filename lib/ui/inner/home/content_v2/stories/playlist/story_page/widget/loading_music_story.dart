import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../app.dart';
import '../../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../../constant/widget/custom_loading.dart';
import '../../notifier.dart';

class LoadingMusicStory extends StatefulWidget {
  final Music apsaraMusic;
  const LoadingMusicStory({Key? key, required this.apsaraMusic}) : super(key: key);

  @override
  State<LoadingMusicStory> createState() => _LoadingMusicStoryState();
}

class _LoadingMusicStoryState extends State<LoadingMusicStory> {
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
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), (){
      final notifier = context.read<StoriesPlaylistNotifier>();
      notifier.urlMusic?.playUrl = '';
      if(globalAudioPlayer != null){
        globalAudioPlayer!.stop();
        globalAudioPlayer!.dispose();
      }

      notifier.initMusic(context, widget.apsaraMusic);
    });

  }
}
