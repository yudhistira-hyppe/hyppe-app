import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
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
    context.incrementAdsCount();
    Future.delayed(Duration.zero, () async{
      if (widget.url.isNotEmpty && widget.data.adsId != null) {
        await System().adsPopUp(context, widget.data, widget.url);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('image home : ${widget.contentData.toJson().toString()} , ${widget.contentData.isApsara}');
    return InteractiveViewer(
      transformationController: widget.transformationController,
      child: InkWell(
        onDoubleTap: () {
          context.read<LikeNotifier>().likePost(context, widget.contentData);
        },
        child: CustomCacheImage(
          // imageUrl: picData.content[arguments].contentUrl,
          imageUrl: widget.contentData.isApsara! ? widget.contentData.mediaThumbUri : widget.contentData.fullThumbPath,
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
}
