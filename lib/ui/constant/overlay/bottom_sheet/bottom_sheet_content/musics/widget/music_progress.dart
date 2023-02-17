import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../widget/custom_icon_widget.dart';

class MusicProgress extends StatefulWidget {
  final Function? onClick;
  final int totalSeconds;
  const MusicProgress({Key? key, this.onClick, required this.totalSeconds}) : super(key: key);

  @override
  State<MusicProgress> createState() => _MusicProgressState();
}

class _MusicProgressState extends State<MusicProgress> with AfterFirstLayoutMixin{
  Timer? timer;
  int seconds = 0;

  void startTimer(){
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        print('current music progress : $seconds');
        seconds++;
      });
    });
  }

  void pauseTimer(){
    timer?.cancel();
  }


  @override
  void dispose() {
    pauseTimer();
    super.dispose();
  }

  @override
  void initState() {
    globalAudioPlayer?.onPlayerStateChanged.listen((event) {
      if(event == PlayerState.paused){
        pauseTimer();
      }else if(event == PlayerState.completed){
        setState(() {
          seconds = 0;
        });
      }
    });
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              value: seconds / widget.totalSeconds,
              color: kHyppeLightIcon,
              backgroundColor: kHyppeLightIcon,
              valueColor: const AlwaysStoppedAnimation(kHyppePrimary),
              strokeWidth: 2,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          height: 50,
          child: IconButton(
            focusColor: Colors.grey,
            icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}stop_icon.svg"),
            splashRadius: 1,
            onPressed: (){
              if(widget.onClick != null){
                widget.onClick!();
              }
            },
          ),
        ),
      ],
    );
  }


}


