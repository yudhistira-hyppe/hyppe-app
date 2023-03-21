import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../../core/services/system.dart';
import '../../../../../../constant/entities/like/notifier.dart';
import '../../../../../../constant/widget/custom_cache_image.dart';

class PicPlaylishScreen extends StatefulWidget {
  final AdsData data;
  final String url;
  final ContentData contentData;
  final TransformationController transformationController;
  const PicPlaylishScreen({Key? key, required this.data, required this.url, required this.contentData, required this.transformationController}) : super(key: key);

  @override
  State<PicPlaylishScreen> createState() => _PicPlaylishScreenState();
}

class _PicPlaylishScreenState extends State<PicPlaylishScreen> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'PicPlaylishScreen');
    context.incrementAdsCount();

    Future.delayed(Duration.zero, () async {
      if (widget.url.isNotEmpty && widget.data.adsId != null) {
        final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
        if (!isShowAds) {
          if (globalAudioPlayer != null) {
            globalAudioPlayer!.pause();
          }
          final count = context.getAdsCount();
          await System().adsPopUp(materialAppKey.currentContext!, widget.data, widget.url, isPopUp: false);
          if (globalAudioPlayer != null) {
            globalAudioPlayer!.resume();
          }
        }
      }
    });
    super.initState();
  }

  @override
  void deactivate() {
    // globalAudioPlayer = null;
    super.deactivate();
  }

  @override
  void dispose() {
    if (globalAudioPlayer != null) {
      disposeGlobalAudio();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: widget.transformationController,
      child: InkWell(
        onDoubleTap: () {
          context.read<LikeNotifier>().likePost(context, widget.contentData);
        },
        child: CustomCacheImage(
          // imageUrl: picData.content[arguments].contentUrl,
          imageUrl: (widget.contentData.isApsara ?? false) ? (widget.contentData.mediaThumbUri ?? (widget.contentData.media?.imageInfo?[0].url ?? '')) : widget.contentData.fullThumbPath,
          imageBuilder: (ctx, imageProvider) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
              ),
            );
          },
          errorWidget: (_, __, ___) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                ),
              ),
            );
          },
          emptyWidget: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('${AssetPath.pngPath}content-error.png'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void initMusic(BuildContext context, String urlMusic) async{
  //   audioPlayer = AudioPlayer();
  //   try {
  //
  //     await audioPlayer.setReleaseMode(ReleaseMode.loop);
  //     if(urlMusic.isNotEmpty){
  //       globalAudioPlayer = audioPlayer;
  //       audioPlayer.play(UrlSource(urlMusic));
  //     }else{
  //       throw 'URL Music is empty';
  //     }
  //   }catch(e){
  //     "Error Init Video $e".logger();
  //   }
  // }
}
