import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/grid_content_view.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/size_config.dart';
import '../../../../../core/models/collection/posts/content_v2/content_data.dart';
import '../../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../home/content_v2/profile/self_profile/widget/sensitive_content.dart';

class SearchContentsTab extends StatefulWidget {
  const SearchContentsTab({Key? key}) : super(key: key);

  @override
  State<SearchContentsTab> createState() => _SearchContentsTabState();
}

class _SearchContentsTabState extends State<SearchContentsTab> {
  @override
  Widget build(BuildContext context) {
    final listTab = [
      HyppeType.HyppeVid,
      HyppeType.HyppeDiary,
      HyppeType.HyppePic
    ];
    return Consumer<SearchNotifier>(builder: (context, notifier, _) {
      final language = notifier.language;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16, top: 16),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: CustomTextWidget(
              textToDisplay: language.contents ?? 'Contents',
              textStyle: context.getTextTheme().bodyText1?.copyWith(color: context.getColorScheme().onBackground, fontWeight: FontWeight.w700),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: listTab.map((e) {
                  final isActive = e == notifier.contentTab;
                  return Container(
                    margin:
                    const EdgeInsets.only(right: 12, top: 10, bottom: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: Ink(
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? context.getColorScheme().primary
                              : context.getColorScheme().background,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(18)),
                        ),
                        child: InkWell(
                          onTap: () {
                            notifier.contentTab = e;
                          },
                          borderRadius: const BorderRadius.all(Radius.circular(18)),
                          splashColor: context.getColorScheme().primary,
                          child: Container(
                            alignment: Alignment.center,
                            height: 36,
                            padding: const EdgeInsets.symmetric( horizontal: 16),
                            decoration: BoxDecoration(
                                borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                                border: !isActive
                                    ? Border.all(
                                    color:
                                    context.getColorScheme().secondary,
                                    width: 1)
                                    : null),
                            child: CustomTextWidget(
                              textToDisplay:
                              System().getTitleHyppe(e),
                              textStyle: context.getTextTheme().bodyText2?.copyWith(color: isActive ? context.getColorScheme().background : context.getColorScheme().secondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList()),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Builder(
                builder: (context) {
                  final type = notifier.contentTab;
                  switch(type){
                    case HyppeType.HyppeVid:
                      return GridContentView(type: type, data: notifier.searchVid ?? []);
                    case HyppeType.HyppeDiary:
                      return GridContentView(type: type, data: notifier.searchDiary ?? []);
                    case HyppeType.HyppePic:
                      return GridContentView(type: type, data: notifier.searchPic ?? []);
                  }
                }
              ),
            ),
          )
        ],
      );
    });
  }

  // Widget _gridContentView(BuildContext context, HyppeType type, List<ContentData> data){
  //
  //   return CustomScrollView(
  //     primary: false,
  //     shrinkWrap: true,
  //     slivers: <Widget>[
  //       SliverPadding(
  //         padding: const EdgeInsets.all(10),
  //         sliver: SliverGrid.count(
  //           crossAxisSpacing: 10,
  //           mainAxisSpacing: 10,
  //           crossAxisCount: 3,
  //           childAspectRatio: 1.0,
  //           children: data
  //               .map(
  //                 (e){
  //                   String thumb = System().showUserPicture(e.mediaThumbEndPoint) ?? '';
  //                   if(type == HyppeType.HyppePic){
  //                     thumb = (e.isApsara ?? false)
  //                         ? ( e.media?.imageInfo?[0].url ?? (e.mediaThumbEndPoint ?? ''))
  //                         : System().showUserPicture(e.mediaThumbEndPoint) ?? '';
  //                   }else{
  //                     thumb = (e.isApsara ?? false)
  //                         ? ( e.media?.videoList?[0].coverURL ?? (e.mediaThumbEndPoint ?? ''))
  //                         : System().showUserPicture(e.mediaThumbEndPoint) ?? '';
  //                   }
  //                   switch(type){
  //                     case HyppeType.HyppePic:
  //                       return GestureDetector(
  //                         onTap: (){
  //
  //                         },
  //                         child: Padding(
  //                           padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
  //                           child: e.reportedStatus == 'BLURRED' || e.reportedStatus == 'OWNED'
  //                               ? SensitiveContentProfile(data: e)
  //                               : Stack(
  //                             children: [
  //                               Center(
  //                                 child: CustomContentModeratedWidget(
  //                                   width: double.infinity,
  //                                   height: double.infinity,
  //                                   isSale: false,
  //                                   isSafe: true, //notifier.postData.data.listPic[index].isSafe,
  //                                   thumbnail: thumb,
  //                                 ),
  //                               ),
  //                               // SelectableText(notifier.iw tem1?.pics?[index].isApsara ?? false
  //                               //     ? (notifier.user?.pics?[index].mediaThumbEndPoint ?? '')
  //                               //     : System().showUserPicture(notifier.user?.pics?[index].mediaThumbEndPoint) ?? ''),
  //                               (e.saleAmount ?? 0) > 0
  //                                   ? const Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.all(4.0),
  //                                     child: CustomIconWidget(
  //                                       iconData: "${AssetPath.vectorPath}sale.svg",
  //                                       height: 22,
  //                                       defaultColor: false,
  //                                     ),
  //                                   ))
  //                                   : Container(),
  //                               (e.certified ?? false) && (e.saleAmount ?? 0) == 0
  //                                   ? Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: Padding(
  //                                       padding: const EdgeInsets.all(2.0),
  //                                       child: Container(
  //                                           padding: const EdgeInsets.all(4),
  //                                           child: const CustomIconWidget(
  //                                             iconData: '${AssetPath.vectorPath}ownership.svg',
  //                                             defaultColor: false,
  //                                           ))))
  //                                   : Container()
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     case HyppeType.HyppeDiary:
  //                       return GestureDetector(
  //                         onTap: (){
  //
  //                         },
  //                         child: Padding(
  //                           padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
  //                           child: e.reportedStatus == 'BLURRED' || e.reportedStatus == 'OWNED'
  //                               ? SensitiveContentProfile(data: e)
  //                               : Stack(
  //                             children: [
  //                               Center(
  //                                 child: CustomContentModeratedWidget(
  //                                   width: double.infinity,
  //                                   height: double.infinity,
  //                                   featureType: FeatureType.vid,
  //                                   isSale: false,
  //                                   isSafe: true, //notifier.postData.data.listVid[index].isSafe,
  //                                   thumbnail: thumb,
  //                                 ),
  //                               ),
  //                               (e.saleAmount ?? 0) > 0
  //                                   ? const Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.all(4.0),
  //                                     child: CustomIconWidget(
  //                                       iconData: "${AssetPath.vectorPath}sale.svg",
  //                                       height: 22,
  //                                       defaultColor: false,
  //                                     ),
  //                                   ))
  //                                   : Container(),
  //                               (e.certified ?? false) && (e.saleAmount ?? 0) == 0
  //                                   ? Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: Padding(
  //                                       padding: const EdgeInsets.all(2.0),
  //                                       child: Container(
  //                                           padding: const EdgeInsets.all(4),
  //                                           child: const CustomIconWidget(
  //                                             iconData: '${AssetPath.vectorPath}ownership.svg',
  //                                             defaultColor: false,
  //                                           ))))
  //                                   : Container()
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     case HyppeType.HyppeVid:
  //                       return GestureDetector(
  //                         onTap: (){},
  //                         child: Padding(
  //                           padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
  //                           child: e.reportedStatus == 'BLURRED' || e.reportedStatus == 'OWNED'
  //                               ? SensitiveContentProfile(data: e)
  //                               : Stack(
  //                             children: [
  //                               Center(
  //                                 child: CustomContentModeratedWidget(
  //                                   width: double.infinity,
  //                                   height: double.infinity,
  //                                   featureType: FeatureType.vid,
  //                                   isSale: false,
  //                                   isSafe: true, //notifier.postData.data.listVid[index].isSafe,
  //                                   thumbnail: thumb,
  //                                 ),
  //                               ),
  //                               // SelectableText(notifier.iw tem1?.vids?[index].isApsara ?? false
  //                               //     ? (notifier.user?.vids?[index].mediaThumbEndPoint ?? '')
  //                               //     : System().showUserPicture(notifier.user?.vids?[index].mediaThumbEndPoint) ?? ''),
  //                               (e.saleAmount ?? 0) > 0
  //                                   ? const Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: Padding(
  //                                     padding: const EdgeInsets.all(4.0),
  //                                     child: CustomIconWidget(
  //                                       iconData: "${AssetPath.vectorPath}sale.svg",
  //                                       height: 22,
  //                                       defaultColor: false,
  //                                     ),
  //                                   ))
  //                                   : Container(),
  //                               (e.certified ?? false) && (e.saleAmount ?? 0) == 0
  //                                   ? Align(
  //                                   alignment: Alignment.topRight,
  //                                   child: Padding(
  //                                       padding: const EdgeInsets.all(2.0),
  //                                       child: Container(
  //                                           padding: const EdgeInsets.all(4),
  //                                           child: const CustomIconWidget(
  //                                             iconData: '${AssetPath.vectorPath}ownership.svg',
  //                                             defaultColor: false,
  //                                           ))))
  //                                   : Container()
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                   }
  //
  //             },
  //           )
  //               .toList(),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
