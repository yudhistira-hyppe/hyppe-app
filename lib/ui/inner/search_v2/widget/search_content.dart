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

import '../../../constant/widget/custom_loading.dart';

class SearchContent extends StatefulWidget {
  final FeatureType? featureType;
  const SearchContent({Key? key, this.featureType}) : super(key: key);

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
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
  Widget build(BuildContext context) => Consumer<SearchNotifier>(
    builder: (_, notifier, __){
      final List<ContentData> contents = widget.featureType == FeatureType.vid ? (notifier.searchContent?.vid?.data ?? []) : widget.featureType == FeatureType.diary ? (notifier.searchContent?.diary?.data ?? []): widget.featureType == FeatureType.pic ? (notifier.searchContent?.pict?.data ?? []) : [];
      final lenght = widget.featureType == FeatureType.vid ? notifier.vidCount : widget.featureType == FeatureType.diary ? notifier.diaryCount: widget.featureType == FeatureType.pic ? notifier.picCount : 18;
      final hasNext = widget.featureType == FeatureType.vid ? notifier.vidHasNext : widget.featureType == FeatureType.diary ? notifier.diaryHasNext: widget.featureType == FeatureType.pic ? notifier.picHasNext : false;
      print('SearchContent Status : $lenght , $hasNext, ${contents.length}, ${widget.featureType}');
      print('isLoading Status : ${notifier.isLoading}');
      return !notifier.isLoading ? GridView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: lenght,
        itemBuilder: (context, index) {
          print('ini cari');
          print(index);
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
                context.read<SearchNotifier>().navigateToSeeAllScreen(context, contents, index);
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
                    thumbnail: contents[index].isApsara ?? false
                        ? contents[index].mediaThumbEndPoint ?? ""
                        : System().showUserPicture(widget.featureType != FeatureType.pic ? contents[index].mediaThumbEndPoint : contents[index].mediaEndpoint)!,
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
      ) : SearchShimmer();
    },
      );
}
