import 'dart:ui';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_base_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/widget/pic_top_item.dart';
import 'package:hyppe/ui/inner/live_search/notifier.dart';
import 'package:hyppe/ui/inner/live_search/widget/search_shimmer.dart';
import 'package:provider/provider.dart';

import '../../../constant/widget/custom_loading.dart';

class LiveSearch extends StatefulWidget {
  int index;
  final FeatureType? featureType;
  LiveSearch({Key? key, this.featureType, this.index = 0}) : super(key: key);

  @override
  State<LiveSearch> createState() => _LiveSearchState();
}

class _LiveSearchState extends State<LiveSearch> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    print('ini index ${widget.index}');
    final notifier = Provider.of<LiveSearchNotifier>(context, listen: false);
    _scrollController.addListener(() => notifier.onScrollListenerFirstPage(context, _scrollController));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<LiveSearchNotifier>(
        builder: (_, notifier, __) {
          final List<ContentData> contents = (notifier.searchContentFirstPage?.video ?? []);
          final lenght = widget.featureType == FeatureType.vid
              ? notifier.liveCount
              : widget.featureType == FeatureType.diary
                  ? notifier.diaryCount
                  : widget.featureType == FeatureType.pic
                      ? notifier.picCount
                      : 18;
          final hasNext = widget.featureType == FeatureType.vid
              ? notifier.vidHasNext
              : widget.featureType == FeatureType.diary
                  ? notifier.diaryHasNext
                  : widget.featureType == FeatureType.pic
                      ? notifier.picHasNext
                      : false;
          return !notifier.isLoading
              ? RefreshIndicator(
                  strokeWidth: 2.0,
                  color: Colors.purple,
                  onRefresh: () async {
                    await notifier.onInitialSearchNew(context, widget.featureType ?? FeatureType.vid, reload: true);
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    itemCount: lenght,
                    itemBuilder: (context, index) {
                      try {
                        if (index == contents.length) {
                          return Container();
                        } else if (index == contents.length + 1) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                            child: CustomLoading(size: 4),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            context.read<LiveSearchNotifier>().navigateToSeeAllScreen(context, contents, index);
                          },
                          child: Container(
                            padding: EdgeInsets.all(3 * SizeConfig.scaleDiagonal),
                            child: Stack(
                              children: [
                                contents[index].reportedStatus == 'BLURRED'
                                    ? blur(contents[index])
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CustomContentModeratedWidget(
                                          width: double.infinity,
                                          height: double.infinity,
                                          featureType: widget.featureType ?? FeatureType.other,
                                          isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                          thumbnail: contents[index].isApsara ?? false
                                              ? contents[index].mediaThumbEndPoint ?? ""
                                              : System().showUserPicture(widget.featureType != FeatureType.pic ? contents[index].mediaThumbEndPoint : contents[index].mediaEndpoint) ?? '',
                                        ),
                                      ),
                                PicTopItem(data: contents[index]),
                              ],
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
                  ),
                )
              : LiveSearchShimmer();
        },
      );

  Widget blur(data) {
    return CustomBaseCacheImage(
        widthPlaceHolder: 80,
        heightPlaceHolder: 80,
        imageUrl: (data.isApsara ?? false) ? (data.mediaThumbEndPoint ?? "") : "${data.fullThumbPath}",
        imageBuilder: (context, imageProvider) => Container(
              // margin: margin,
              // const EdgeInsets.symmetric(horizontal: 4.5),
              // width: _scaling,
              height: 168,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ClipRect(
                  child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 30.0,
                  sigmaY: 30.0,
                ),
                child: Container(
                  alignment: Alignment.center,
                  width: 200.0,
                  height: 200.0,
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
              )),
            ),
        emptyWidget: Container());
  }
}
