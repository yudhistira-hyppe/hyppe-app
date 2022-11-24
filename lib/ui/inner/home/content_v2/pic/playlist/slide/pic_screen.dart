import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/bloc/posts_v2/bloc.dart';
import '../../../../../../../core/bloc/posts_v2/state.dart';
import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/models/collection/advertising/ads_video_data.dart';
import '../../../../../../../core/models/collection/music/music.dart';
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

  BetterPlayerController? _betterPlayerController;
  bool _isLoadVideo = false;

  @override
  void initState() {
    context.incrementAdsCount();
    if(widget.contentData.apsaraId != null && widget.contentData.music?.id != null){
      initVideo(context, widget.contentData.apsaraId!);
    }

    Future.delayed(Duration.zero, () async {
      if (widget.url.isNotEmpty && widget.data.adsId != null) {
        final isShowAds = SharedPreference().readStorage(SpKeys.isShowPopAds);
        if (!isShowAds) {
          await System().adsPopUp(context, widget.data, widget.url);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if(_betterPlayerController != null){
      _betterPlayerController!.pause();
      _betterPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.contentData.music?.id != null){
      return _isLoadVideo ? const Center(
        child: CustomLoading(),
      ) : _betterPlayerController == null ? const Center(
        child: CustomLoading(),
      ): (_betterPlayerController!.isVideoInitialized() ?? false) ? InteractiveViewer(
        transformationController: widget.transformationController,
        child: InkWell(
          onDoubleTap: () {
            context.read<LikeNotifier>().likePost(context, widget.contentData);
          },
          child: Platform.isAndroid
              ? AspectRatio(
            child: BetterPlayer(controller: _betterPlayerController!),
            aspectRatio: _betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 1,
          )
              : BetterPlayer(controller: _betterPlayerController!),
        ),
      ): const Center(
        child: CustomLoading(),
      );
    }else{
      return InteractiveViewer(
        transformationController: widget.transformationController,
        child: InkWell(
          onDoubleTap: () {
            context.read<LikeNotifier>().likePost(context, widget.contentData);
          },
          child: CustomCacheImage(
            // imageUrl: picData.content[arguments].contentUrl,
            imageUrl: (widget.contentData.isApsara ?? false) ? widget.contentData.mediaEndpoint : widget.contentData.fullThumbPath,
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
          ),
        ),
      );
    }
    // print('PicPlaylishScreen : ${widget.contentData.isApsara} = ${widget.contentData.mediaEndpoint}, ${widget.contentData.fullThumbPath}');

  }

  void initVideo(BuildContext context, String apsaraId) async{
    BetterPlayerConfiguration betterPlayerConfiguration = const BetterPlayerConfiguration(
      autoPlay: false,
      fit: BoxFit.contain,
      showPlaceholderUntilPlay: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        enableFullscreen: false,
        controlBarColor: Colors.black26,
      ),
    );
    final _url = await _getAdsVideoApsara(context, apsaraId);
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      _url != null
          ? Platform.isIOS
          ? _url.replaceAll(" ", "%20")
          : _url
          : '',
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: BetterPlayerBufferingConfiguration.defaultMinBufferMs,
        maxBufferMs: BetterPlayerBufferingConfiguration.defaultMaxBufferMs,
        bufferForPlaybackMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackMs,
        bufferForPlaybackAfterRebufferMs: BetterPlayerBufferingConfiguration.defaultBufferForPlaybackAfterRebufferMs,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);

    try {
      setState(() {
        _isLoadVideo = true;
      });

      await _betterPlayerController?.setupDataSource(dataSource).then((_) {
        setState(() {
          _betterPlayerController?.play();
          _betterPlayerController?.setLooping(true);
          _betterPlayerController?.setOverriddenAspectRatio(_betterPlayerController?.videoPlayerController?.value.aspectRatio ?? 0.0);
        });

      });

    }catch(e){
      "Error Init Video $e".logger();
    } finally {
      _isLoadVideo = false;
    }
  }

  Future<String?> _getAdsVideoApsara(BuildContext context, String apsaraId) async {
    try {
      final notifier = PostsBloc();
      await notifier.getVideoApsaraBlocV2(context, apsaraId: apsaraId);

      final fetch = notifier.postsFetch;

      if (fetch.postsState == PostsState.videoApsaraSuccess) {
        Map jsonMap = json.decode(fetch.data.toString());
        print('jsonMap video Apsara : $jsonMap');
        return jsonMap['PlayUrl'];
      }
    } catch (e) {
      'Failed to fetch ads data ${e}'.logger();
    }
    return null;
  }
}
