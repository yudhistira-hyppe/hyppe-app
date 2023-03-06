import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/constants/size_config.dart';
import '../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../core/services/system.dart';
import '../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../constant/widget/custom_icon_widget.dart';
import '../../home/content_v2/profile/self_profile/widget/sensitive_content.dart';

class GridContentView extends StatelessWidget {
  HyppeType type;
  List<ContentData> data;
  bool hasNext;
  GridContentView({Key? key, required this.type, required this.data, this.hasNext = false}) : super(key: key);

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
            children: data
                .map(
                  (e){
                String thumb = System().showUserPicture(e.mediaThumbEndPoint) ?? '';
                if(type == HyppeType.HyppePic){
                  thumb = (e.isApsara ?? false)
                      ? ( e.media?.imageInfo?[0].url ?? (e.mediaThumbEndPoint ?? ''))
                      : System().showUserPicture(e.mediaThumbEndPoint) ?? '';
                }else{
                  thumb = (e.isApsara ?? false)
                      ? ( e.media?.videoList?[0].coverURL ?? (e.mediaThumbEndPoint ?? ''))
                      : System().showUserPicture(e.mediaThumbEndPoint) ?? '';
                }
                switch(type){
                  case HyppeType.HyppePic:
                    return GestureDetector(
                      onTap: (){

                      },
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: e.reportedStatus == 'BLURRED' || e.reportedStatus == 'OWNED'
                            ? SensitiveContentProfile(data: e)
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
                            (e.saleAmount ?? 0) > 0
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
                            (e.certified ?? false) && (e.saleAmount ?? 0) == 0
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

                      },
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: e.reportedStatus == 'BLURRED' || e.reportedStatus == 'OWNED'
                            ? SensitiveContentProfile(data: e)
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
                            (e.saleAmount ?? 0) > 0
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
                            (e.certified ?? false) && (e.saleAmount ?? 0) == 0
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
                      onTap: (){},
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: e.reportedStatus == 'BLURRED' || e.reportedStatus == 'OWNED'
                            ? SensitiveContentProfile(data: e)
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
                            (e.saleAmount ?? 0) > 0
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
                            (e.certified ?? false) && (e.saleAmount ?? 0) == 0
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

              },
            )
                .toList(),
          ),
        ),
        if(hasNext)
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
}
