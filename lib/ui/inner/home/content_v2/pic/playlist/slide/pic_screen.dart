import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
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

  var audioPlayer = AudioPlayer();
  bool _isLoadMusic = false;

  @override
  void initState() {
    context.incrementAdsCount();
    if(widget.contentData.music?.apsaraMusic != null){
      initMusic(context, widget.contentData.music!.apsaraMusic!);
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
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadMusic ? const Center(
      child: CustomLoading(),
    ) : InteractiveViewer(
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

  void initMusic(BuildContext context, String apsaraId) async{
    audioPlayer = AudioPlayer();
    try {

      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      setState(() {
        _isLoadMusic = true;
      });
      final urlMusic = await _getAdsVideoApsara(context, apsaraId);
      if(urlMusic != null){
        audioPlayer.play(UrlSource(urlMusic));
      }else{
        throw 'URL Music is null';
      }
    }catch(e){
      "Error Init Video $e".logger();
    } finally {
      setState(() {
        _isLoadMusic = false;
      });

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
