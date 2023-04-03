import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../core/models/collection/music/music.dart';
import '../../../../../core/services/route_observer_service.dart';
import '../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../../constant/widget/custom_spacer.dart';
import '../../../../constant/widget/custom_text_widget.dart';

class MusicStatusSelected extends StatefulWidget {
  final Music music;
  final bool isDrag;
  final bool isPlay;
  Function? onClose;
  MusicStatusSelected({Key? key, required this.music, this.onClose, this.isPlay = true, this.isDrag = false}) : super(key: key);

  @override
  State<MusicStatusSelected> createState() => _MusicStatusSelectedState();
}

class _MusicStatusSelectedState extends State<MusicStatusSelected> with RouteAware, AfterFirstLayoutMixin{

  @override
  Widget build(BuildContext context) {
    final titleMusic = '${widget.music.musicTitle} - ${widget.music.artistName}';
    final lengthTitle = titleMusic.length;
    return Container(
      height: 40,
      width: context.getWidth() * 0.7,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          widget.isDrag ? const CustomIconWidget(
            height: 20,
            width: 20,
            iconData: "${AssetPath.vectorPath}close_ads.svg",
          ): InkWell(
            onTap: () {
              if(widget.onClose != null){
                widget.onClose!();
              }
              //
            },
            child: const CustomIconWidget(
              height: 20,
              width: 20,
              iconData: "${AssetPath.vectorPath}close_ads.svg",
            ),
          ),
          fourPx,
          Container(
            width: 1,
            height: 13,
            color: kHyppeGrey,
          ),
          sixPx,
          Expanded(
            child: lengthTitle > 20 ? Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 25,
                  child: Marquee(text: '$titleMusic  ', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),)),
            ) : CustomTextWidget(
              textOverflow: TextOverflow.ellipsis,
              maxLines: 1,
              textToDisplay: '${widget.music.musicTitle} - ${widget.music.artistName}',
              textStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          )
        ],
      ),
    );
  }


  @override
  void dispose() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer.stop();
    notifier.audioPreviewPlayer.dispose();
    CustomRouteObserver.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    if(widget.isPlay){
      settingAudio();
    }
    super.initState();
  }

  void settingAudio() async{
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer = AudioPlayer();
    await notifier.audioPreviewPlayer.setReleaseMode(ReleaseMode.loop);
    final url = widget.music.apsaraMusicUrl?.playUrl;
    if(url != null){
      notifier.audioPreviewPlayer.play(UrlSource(url));
    }
  }


  @override
  void deactivate() {
    print('deactivate MusicStatusSelected false');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer.pause();
    super.deactivate();
  }

  @override
  void didPop() {
    print('didPop MusicStatusSelected false');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer.pause();
    super.didPop();
  }

  @override
  void didPush() {
    print('didPop MusicStatusSelected false');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer.pause();
    super.didPush();
  }

  @override
  void didPopNext() {
    print('didPopNext MusicStatusSelected true');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer.resume();
    super.didPopNext();
  }

  @override
  void didPushNext() {
    print('didPushNext MusicStatusSelected false');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPreviewPlayer.pause();
    super.didPushNext();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    print('afterFirstLayout MusicStatusSelected');
    try{
      CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
    }catch(e){
      e.logger();
    }

  }

  @override
  void didChangeDependencies() {
    try{
      CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    }catch(e){
      e.logger();
    }

    super.didChangeDependencies();
  }
}
