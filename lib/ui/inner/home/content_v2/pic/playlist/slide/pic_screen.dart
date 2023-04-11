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
  final Function()? preventedAction;
  final Function()? afterAction;
  const PicPlaylishScreen({Key? key, required this.data, required this.url, required this.contentData, this.preventedAction, this.afterAction}) : super(key: key);

  @override
  State<PicPlaylishScreen> createState() => _PicPlaylishScreenState();
}

class _PicPlaylishScreenState extends State<PicPlaylishScreen> with SingleTickerProviderStateMixin {
  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;
  final double minScale = 1;
  final double maxScale = 4;
  @override
  void initState() {
    transformationController = TransformationController();
    animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
    )..addListener(() {
      transformationController.value = animation!.value;
    });
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
    transformationController.dispose();
    animationController.dispose();
    if (globalAudioPlayer != null) {
      disposeGlobalAudio();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        context.read<LikeNotifier>().likePost(context, widget.contentData);
      },
      child: InteractiveViewer(
        clipBehavior: Clip.none,
        transformationController: transformationController,
        panEnabled: false,
        minScale: minScale,
        maxScale: maxScale,
        onInteractionEnd: (details){
          resetAnimation();
        },
        onInteractionStart: (details){
          if(widget.preventedAction != null){
            widget.preventedAction!();
          }
        },
        child: ClipRRect(
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
      ),
    );
  }


  void resetAnimation(){
    animation = Matrix4Tween(
      begin: transformationController.value,
      end: Matrix4.identity()
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.linear));

    animationController.forward(from: 0);
    if(widget.afterAction != null){
      widget.afterAction!();
    }
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
