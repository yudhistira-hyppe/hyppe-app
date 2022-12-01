import 'dart:ui';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_shimmer.dart';
import 'package:provider/provider.dart';

class ContentSearch extends StatefulWidget {
  final List<ContentData>? content;
  final FeatureType? featureType;
  final int? selectIndex;
  const ContentSearch({Key? key, this.content, this.featureType, this.selectIndex}) : super(key: key);

  @override
  State<ContentSearch> createState() => ContentSearchState();
}

class ContentSearchState extends State<ContentSearch> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    _scrollController.addListener(() => notifier.onScrollListener(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.content != null
      ? GridView.builder(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: widget.content?.length,
          itemBuilder: (context, index) {
            var gambar = '';
            if (widget.content?[index].postType == 'pict') {
              if (widget.content?[index].isApsara ?? false) {
                gambar = widget.content?[index].media?.imageInfo?[0].url ?? '';
              } else {
                gambar = System().showUserPicture(widget.featureType != FeatureType.pic ? (widget.content?[index].mediaThumbEndPoint ?? '') : widget.content?[index].mediaEndpoint) ?? '';
              }
            } else {
              if (widget.content?[index].isApsara ?? false) {
                gambar = widget.content?[index].media?.videoList?[0].coverURL ?? '';
              } else {
                gambar = System().showUserPicture(widget.featureType != FeatureType.pic ? (widget.content?[index].mediaThumbEndPoint ?? '') : widget.content?[index].mediaEndpoint) ?? '';
              }
            }
            try {
              return GestureDetector(
                onTap: () {
                  context.read<SearchNotifier>().navigateToSeeAllScreen2(context, widget.content ?? [], index, widget.selectIndex ?? 0);
                },
                child: Container(
                  padding: EdgeInsets.all(3 * SizeConfig.scaleDiagonal),
                  child: widget.content?[index].reportedStatus == 'BLURRED'
                      ? blur(gambar)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CustomContentModeratedWidget(
                            width: double.infinity,
                            height: double.infinity,
                            featureType: widget.featureType ?? FeatureType.other,
                            isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                            thumbnail: gambar,
                          ),
                        ),
                ),
              );
            } catch (e) {
              print('[DevError] => ${e.toString()}');
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('${AssetPath.pngPath}filter_search-error.png'), fit: BoxFit.fill),
                ),
              );
            }
          },
        )
      : SearchShimmer();

  Widget blur(gambar) {
    return CustomBaseCacheImage(
      widthPlaceHolder: 80,
      heightPlaceHolder: 80,
      imageUrl: gambar,
      imageBuilder: (context, imageProvider) => Container(
        // margin: margin,
        // const EdgeInsets.symmetric(horizontal: 4.5),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _buildBody(context),
      ),
      errorWidget: (context, url, error) => Container(
        // margin: margin,
        // const EdgeInsets.symmetric(horizontal: 4.5),
        width: double.infinity,
        height: double.infinity,
        child: _buildBody(context),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('${AssetPath.pngPath}content-error.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      emptyWidget: Container(
        // margin: margin,
        // const EdgeInsets.symmetric(horizontal: 4.5),
        width: double.infinity,
        height: double.infinity,
        child: _buildBody(context),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('${AssetPath.pngPath}content-error.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildBody(context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 30.0,
          sigmaY: 30.0,
        ),
        child: Container(
          alignment: Alignment.center,
          width: (MediaQuery.of(context).size.width - 11.5 - 11.5 - 9) / 2,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CustomIconWidget(
                iconData: "${AssetPath.vectorPath}eye-off.svg",
                defaultColor: false,
                height: 30,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
