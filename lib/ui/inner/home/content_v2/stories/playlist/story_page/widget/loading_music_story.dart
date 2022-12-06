import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../app.dart';
import '../../../../../../../../core/models/collection/music/music.dart';
import '../../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../../constant/widget/custom_loading.dart';
import '../../notifier.dart';

class LoadingMusicStory extends StatefulWidget {
  final Music apsaraMusic;
  const LoadingMusicStory({Key? key, required this.apsaraMusic}) : super(key: key);

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
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<StoriesPlaylistNotifier>();
    notifier.urlMusic?.playUrl = '';
    if(globalAudioPlayer != null){
      disposeGlobalAudio();
    }

    notifier.initMusic(context, widget.apsaraMusic);
  }
}
