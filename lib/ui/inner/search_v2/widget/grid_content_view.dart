import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/constants/size_config.dart';
import '../../../../core/constants/utils.dart';
import '../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../core/services/system.dart';
import '../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../home/content_v2/profile/self_profile/widget/sensitive_content.dart';

class GridContentView extends StatefulWidget {
  HyppeType type;
  List<ContentData> data;
  GridContentView({Key? key, required this.type, required this.data}) : super(key: key);

  @override
  State<GridContentView> createState() => _GridContentViewState();
}

class _GridContentViewState extends State<GridContentView> {

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'GridContentView');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: false,
      shrinkWrap: true,
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              children: List.generate(widget.data.length, (index) {
                final dataitem = widget.data[index];
                String thumb = System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
                if (widget.type == HyppeType.HyppePic) {
                  final imageInfo = dataitem.media?.imageInfo;
                  if(imageInfo.isNotNullAndEmpty()){
                    thumb = (dataitem.isApsara ?? false) ? (imageInfo?[0].url ?? (dataitem.mediaThumbEndPoint ?? '')) : System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
                  }

                } else {
                  final imageInfo = dataitem.media?.videoList;
                  if(imageInfo.isNotNullAndEmpty()){
                    thumb = (dataitem.isApsara ?? false) ? (dataitem.media?.videoList?[0].coverURL ?? (dataitem.mediaThumbEndPoint ?? '')) : System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
                  }

                }
                // print('GridContentView URL Image: $thumb');

                switch (widget.type) {
                  case HyppeType.HyppePic:
                    return GestureDetector(
                      onTap: () {
                        context.read<SearchNotifier>().navigateToSeeAllScreen3(context, widget.data, index, widget.type);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: dataitem.reportedStatus == 'BLURRED' || dataitem.reportedStatus == 'OWNED'
                            ? SensitiveContentProfile(data: dataitem)
                            : Stack(
                                children: [
                                  Center(
                                    child: CustomContentModeratedWidget(
                                      width: double.infinity,
                                      height: double.infinity,
                                      isSale: false,
                                      isSafe: true, //notifier.postData.data.listPic[index].isSafe,
                                      thumbnail: ImageUrl(dataitem.postID, url: thumb),
                                    ),
                                  ),
                                  // SelectableText(notifier.iw tem1?.pics?[index].isApsara ?? false
                                  //     ? (notifier.user?.pics?[index].mediaThumbEndPoint ?? '')
                                  //     : System().showUserPicture(notifier.user?.pics?[index].mediaThumbEndPoint) ?? ''),
                                  (dataitem.saleAmount ?? 0) > 0
                                      ? const Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: CustomIconWidget(
                                              iconData: "${AssetPath.vectorPath}sale.svg",
                                              height: 22,
                                              defaultColor: false,
                                            ),
                                          ))
                                      : Container(),
                                  (dataitem.certified ?? false) && (dataitem.saleAmount ?? 0) == 0
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  child: const CustomIconWidget(
                                                    iconData: '${AssetPath.vectorPath}ownership.svg',
                                                    defaultColor: false,
                                                  ))))
                                      : Container()
                                ],
                              ),
                      ),
                    );
                  case HyppeType.HyppeDiary:
                    return GestureDetector(
                      onTap: () {
                        context.read<SearchNotifier>().navigateToSeeAllScreen3(context, widget.data, index, widget.type);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: dataitem.reportedStatus == 'BLURRED' || dataitem.reportedStatus == 'OWNED'
                            ? SensitiveContentProfile(data: dataitem)
                            : Stack(
                                children: [
                                  Center(
                                    child: CustomContentModeratedWidget(
                                      width: double.infinity,
                                      height: double.infinity,
                                      featureType: FeatureType.vid,
                                      isSale: false,
                                      isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                      thumbnail: ImageUrl(dataitem.postID, url: thumb),
                                    ),
                                  ),
                                  (dataitem.saleAmount ?? 0) > 0
                                      ? const Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: CustomIconWidget(
                                              iconData: "${AssetPath.vectorPath}sale.svg",
                                              height: 22,
                                              defaultColor: false,
                                            ),
                                          ))
                                      : Container(),
                                  (dataitem.certified ?? false) && (dataitem.saleAmount ?? 0) == 0
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  child: const CustomIconWidget(
                                                    iconData: '${AssetPath.vectorPath}ownership.svg',
                                                    defaultColor: false,
                                                  ))))
                                      : Container()
                                ],
                              ),
                      ),
                    );
                  case HyppeType.HyppeVid:
                    return GestureDetector(
                      onTap: () {
                        context.read<SearchNotifier>().navigateToSeeAllScreen3(context, widget.data, index, widget.type);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: dataitem.reportedStatus == 'BLURRED' || dataitem.reportedStatus == 'OWNED'
                            ? SensitiveContentProfile(data: dataitem)
                            : Stack(
                                children: [
                                  Center(
                                    child: CustomContentModeratedWidget(
                                      width: double.infinity,
                                      height: double.infinity,
                                      featureType: FeatureType.vid,
                                      isSale: false,
                                      isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                      thumbnail: ImageUrl(dataitem.postID, url: thumb),
                                    ),
                                  ),
                                  // SelectableText(notifier.iw tem1?.vids?[index].isApsara ?? false
                                  //     ? (notifier.user?.vids?[index].mediaThumbEndPoint ?? '')
                                  //     : System().showUserPicture(notifier.user?.vids?[index].mediaThumbEndPoint) ?? ''),
                                  (dataitem.saleAmount ?? 0) > 0
                                      ? const Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: CustomIconWidget(
                                              iconData: "${AssetPath.vectorPath}sale.svg",
                                              height: 22,
                                              defaultColor: false,
                                            ),
                                          ))
                                      : Container(),
                                  (dataitem.certified ?? false) && (dataitem.saleAmount ?? 0) == 0
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  child: const CustomIconWidget(
                                                    iconData: '${AssetPath.vectorPath}ownership.svg',
                                                    defaultColor: false,
                                                  ))))
                                      : Container()
                                ],
                              ),
                      ),
                    );
                }
              }).toList()),
        ),
        if (widget.data.length % limitSearch == 0)
          SliverToBoxAdapter(
            child: Container(width: double.infinity, height: 50, alignment: Alignment.center, child: const CustomLoading()),
          )
      ],
    );
  }
}
