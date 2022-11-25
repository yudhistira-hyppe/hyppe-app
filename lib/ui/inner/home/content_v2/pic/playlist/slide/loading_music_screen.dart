import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/playlist/slide/notifier.dart';
import 'package:provider/provider.dart';

class LoadingMusicScreen extends StatefulWidget {
  final String apsaraMusic;
  const LoadingMusicScreen({Key? key, required this.apsaraMusic}) : super(key: key);

  @override
  State<LoadingMusicScreen> createState() => _LoadingMusicScreenState();
}

class _LoadingMusicScreenState extends State<LoadingMusicScreen> {

  @override
  void initState() {
    print('initState LoadingMusicScreen');
    Future.delayed(Duration(milliseconds: 500), (){
      final notifier = context.read<SlidedPicDetailNotifier>();
      notifier.urlMusic = '';
      if(globalAudioPlayer != null){
        globalAudioPlayer!.stop();
        globalAudioPlayer!.dispose();
      }

      notifier.initMusic(context, widget.apsaraMusic);
    });

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CustomLoading(),
    );
  }


}
