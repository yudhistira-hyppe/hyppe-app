import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

import '../../../../../../../app.dart';
import '../notifier.dart';

class LoadingDetailMusicScreen extends StatefulWidget {
  final String apsaraMusic;
  const LoadingDetailMusicScreen({Key? key, required this.apsaraMusic}) : super(key: key);

  @override
  State<LoadingDetailMusicScreen> createState() => _LoadingDetailMusicScreenState();
}

class _LoadingDetailMusicScreenState extends State<LoadingDetailMusicScreen> {


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
    FirebaseCrashlytics.instance.setCustomKey('layout', 'LoadingDetailMusicScreen');
    super.initState();
    final notifier = context.read<PicDetailNotifier>();
    notifier.urlMusic = '';
    if(globalAudioPlayer != null){
      disposeGlobalAudio();
    }

    notifier.initMusic(context, widget.apsaraMusic);
  }
}
