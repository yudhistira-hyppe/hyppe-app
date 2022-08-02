import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:flutter/material.dart';
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
            try {
              return GestureDetector(
                onTap: () {
                  print('asdasd 33');
                  context.read<SearchNotifier>().navigateToSeeAllScreen2(context, widget.content!, index, widget.selectIndex!);
                },
                child: Container(
                  padding: EdgeInsets.all(3 * SizeConfig.scaleDiagonal),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomContentModeratedWidget(
                      width: double.infinity,
                      height: double.infinity,
                      featureType: widget.featureType!,
                      isSafe: true, //notifier.postData!.data.listVid[index].isSafe!,
                      thumbnail: System().showUserPicture(widget.featureType != FeatureType.pic ? widget.content![index].mediaThumbEndPoint : widget.content![index].mediaEndpoint)!,
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
}
