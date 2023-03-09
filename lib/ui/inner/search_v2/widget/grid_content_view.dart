import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_no_result_image.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/constants/size_config.dart';
import '../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../core/services/system.dart';
import '../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../home/content_v2/profile/self_profile/widget/sensitive_content.dart';


class GridContentView extends StatefulWidget {
  HyppeType type;
  List<ContentData> data;
  bool hasNext;
  GridContentView({Key? key, required this.type, required this.data, this.hasNext = false}) : super(key: key);

  @override
  State<GridContentView> createState() => _GridContentViewState();
}

class _GridContentViewState extends State<GridContentView>{

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(
      builder: (context, notifier, _) {
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
                children: widget.data.isNotEmpty ? List.generate(widget.data.length, (index){
                  final dataitem = widget.data[index];
                  String thumb = System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
                  if(widget.type == HyppeType.HyppePic){
                    thumb = (dataitem.isApsara ?? false)
                        ? ( dataitem.media?.imageInfo?[0].url ?? (dataitem.mediaThumbEndPoint ?? ''))
                        : System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
                  }else{
                    thumb = (dataitem.isApsara ?? false)
                        ? ( dataitem.media?.videoList?[0].coverURL ?? (dataitem.mediaThumbEndPoint ?? ''))
                        : System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
                  }
                  // print('GridContentView URL Image: $thumb');

                  switch(widget.type){
                    case HyppeType.HyppePic:
                      return GestureDetector(
                        onTap: (){
                          notifier.navigateToSeeAllScreen3(context, widget.data, index, widget.type);
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
                                  thumbnail: thumb,
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
                        onTap: (){
                          notifier.navigateToSeeAllScreen3(context, widget.data, index, widget.type);
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
                                  thumbnail: thumb,
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
                        onTap: (){
                          notifier.navigateToSeeAllScreen3(context, widget.data, index, widget.type);
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
                                  thumbnail: thumb,
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
                }).toList() : [
                  SearchNoResultImage(locale: notifier.language, keyword: '')
                ],
              ),
            ),
            if(widget.hasNext)
              SliverToBoxAdapter(
                child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    child: const CustomLoading()),
              )
          ],
        );
      }
    );
  }


}

