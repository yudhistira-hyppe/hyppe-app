import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
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
  Function? onClose;
  MusicStatusSelected({Key? key, required this.music, this.onClose}) : super(key: key);

  @override
  State<MusicStatusSelected> createState() => _MusicStatusSelectedState();
}

class _MusicStatusSelectedState extends State<MusicStatusSelected> with RouteAware, AfterFirstLayoutMixin{

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 40),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: const BorderRadius.all(Radius.circular(16))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if(widget.onClose != null){
                widget.onClose!();
              }
              //
            },
            child: const CustomIconWidget(
              height: 12,
              width: 12,
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
            child: CustomTextWidget(
              textOverflow: TextOverflow.ellipsis,
              maxLines: 3,
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
    settingAudio();
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
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }
}
