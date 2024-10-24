import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../../core/constants/asset_path.dart';
import '../../../../../core/constants/size_config.dart';
import '../../../../../core/models/collection/search/search_content.dart';
import '../../../../../core/services/system.dart';
import '../../../../constant/widget/custom_content_moderated_widget.dart';
import '../../../../constant/widget/custom_icon_widget.dart';
import '../../../../constant/widget/custom_loading.dart';
import '../../../home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import '../../../home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import '../../notifier.dart';
import '../../widget/search_no_result_image.dart';

class GridHashtagPic extends StatefulWidget {
  final String tag;
  final double top;
  final ScrollController controller;
  const GridHashtagPic({Key? key, required this.tag, required this.controller, required this.top}) : super(key: key);

  @override
  State<GridHashtagPic> createState() => _GridHashtagPicState();
}

class _GridHashtagPicState extends State<GridHashtagPic> {

  double heightItem = 0.0;

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'GridHashtagPic');
    return MeasuredSize(
      onChange: (value){
        if(mounted){
          setState(() {
            heightItem = value.height;
          });
        }

      },
      child: Selector<SearchNotifier, Tuple3<SearchContentModel?, int, bool>>(
          selector: (_, select) =>Tuple3(select.detailHashTag, select.detailHashTag?.pict?.length ?? 0, select.loadTagDetail),
          builder: (context, ref, _) {
            String tag = '';
            if(ref.item1?.tags?.isNotEmpty ?? false){
              tag = ref.item1?.tags?[0].tag ?? '';
            }else{
              tag = '#${widget.tag}';
            }
            return !ref.item3 ? ref.item2 == 0 ? SliverToBoxAdapter(child: SearchNoResultImage(locale: context.read<SearchNotifier>().language, keyword: tag)) : SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(

                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index){
                    try {

                      final dataitem = ref.item1?.pict?[index];
                      String thumb = System().showUserPicture(dataitem?.mediaThumbEndPoint) ?? '';
                      ImageBlob? blob;
                      if(dataitem?.blob != null){
                        blob = ImageBlob(dataitem?.postID, data: dataitem!.blob!);
                      }else{
                        final imageInfo = dataitem?.media?.imageInfo;
                        if(imageInfo.isNotNullAndEmpty()){
                          thumb = (dataitem?.isApsara ?? false)
                              ? (dataitem?.mediaThumbEndPoint ?? '')
                              : System().showUserPicture(dataitem?.mediaThumbEndPoint) ?? '';

                        }
                      }

                      // else{
                      //   if(!(dataitem?.isApsara ?? true)){
                      //     final imageUrl = System().showUserPicture(dataitem?.mediaThumbEndPoint);
                      //     if(imageUrl?.isNotEmpty ?? false){
                      //       final id = dataitem?.postID;
                      //       if(id != null){
                      //         System().saveThumbnail(imageUrl!, id, isCheck: true);
                      //       }
                      //     }
                      //   }
                      // }

                      return GestureDetector(
                        onTap: () => context.read<SearchNotifier>().navigateToSeeAllScreen4(context, ref.item1?.pict ?? [], index, HyppeType.HyppePic, TypeApiSearch.detailHashTag, tag, PageSrc.hashtag, widget.controller, heightItem, widget.top),
                        child: Padding(
                          padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                          child: dataitem?.reportedStatus == 'BLURRED'
                              ? SensitiveContentProfile(data: dataitem)
                              : Stack(
                            children: [
                              Center(
                                child: CustomContentModeratedWidget(
                                  width: double.infinity,
                                  height: double.infinity,
                                  isSale: false,
                                  isSafe: true, //notifier.postData.data.listPic[index].isSafe,
                                  thumbnail: blob ?? ImageUrl(dataitem?.postID, url: thumb),
                                  placeHolder: UnconstrainedBox(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 35 * SizeConfig.scaleDiagonal,
                                      height: 35 * SizeConfig.scaleDiagonal,
                                      child: const CustomLoading(),
                                    ),
                                  ),
                                ),
                              ),
                              (dataitem?.saleAmount ?? 0) > 0
                                  ? const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}sale.svg",
                                      height: 22,
                                      defaultColor: false,
                                    ),
                                  ))
                                  : Container(),
                              (dataitem?.certified ?? false) && (dataitem?.saleAmount ?? 0) == 0
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
                    } catch (e) {
                      print('[DevError] => ${e.toString()}');
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
                        ),
                      );
                    }
                  },
                  childCount: ref.item2,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,),
              ),
            ) : BothProfileContentShimmer();
            // return SliverGrid(
            //   delegate: SliverChildBuilderDelegate(
            //         (BuildContext context, int index) {
            //       try {
            //         final dataitem = ref.item1[index];
            //         String thumb = System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
            //         thumb = (dataitem.isApsara ?? false)
            //             ? ( dataitem.media?.imageInfo?[0].url ?? (dataitem.mediaThumbEndPoint ?? ''))
            //             : System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
            //
            //         return GestureDetector(
            //           onTap: () => context.read<SearchNotifier>().navigateToSeeAllScreen3(context, ref.item1, index, HyppeType.HyppeVid),
            //           child: Padding(
            //             padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
            //             child: dataitem.reportedStatus == 'BLURRED'
            //                 ? SensitiveContentProfile(data: dataitem)
            //                 : Stack(
            //               children: [
            //                 Center(
            //                   child: CustomContentModeratedWidget(
            //                     width: double.infinity,
            //                     height: double.infinity,
            //                     isSale: false,
            //                     featureType: FeatureType.vid,
            //                     isSafe: true, //notifier.postData.data.listVid[index].isSafe,
            //                     thumbnail: thumb,
            //                   ),
            //                 ),
            //                 (dataitem.saleAmount ?? 0) > 0
            //                     ? const Align(
            //                     alignment: Alignment.topRight,
            //                     child: Padding(
            //                       padding: EdgeInsets.all(4.0),
            //                       child: CustomIconWidget(
            //                         iconData: "${AssetPath.vectorPath}sale.svg",
            //                         height: 22,
            //                         defaultColor: false,
            //                       ),
            //                     ))
            //                     : Container(),
            //                 (dataitem.certified ?? false) && (dataitem.saleAmount ?? 0) == 0
            //                     ? Align(
            //                     alignment: Alignment.topRight,
            //                     child: Padding(
            //                         padding: const EdgeInsets.all(2.0),
            //                         child: Container(
            //                             padding: const EdgeInsets.all(4),
            //                             child: const CustomIconWidget(
            //                               iconData: '${AssetPath.vectorPath}ownership.svg',
            //                               defaultColor: false,
            //                             ))))
            //                     : Container()
            //               ],
            //             ),
            //           ),
            //         );
            //       } catch (e) {
            //         print('[DevError] => ${e.toString()}');
            //         return Container(
            //           width: double.infinity,
            //           height: double.infinity,
            //           decoration: const BoxDecoration(
            //             image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
            //           ),
            //         );
            //       }
            //     },
            //     childCount: ref.item2,
            //   ),
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            // );
            // return CustomScrollView(
            //   primary: false,
            //   shrinkWrap: true,
            //   slivers: <Widget>[
            //     SliverPadding(
            //       padding: const EdgeInsets.all(10),
            //       sliver: SliverGrid.count(
            //           crossAxisSpacing: 10,
            //           mainAxisSpacing: 10,
            //           crossAxisCount: 3,
            //           childAspectRatio: 1.0,
            //           children: List.generate(ref.item2, (index){
            //             final dataitem = ref.item1[index];
            //             String thumb = System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
            //             thumb = (dataitem.isApsara ?? false)
            //                 ? ( dataitem.media?.imageInfo?[0].url ?? (dataitem.mediaThumbEndPoint ?? ''))
            //                 : System().showUserPicture(dataitem.mediaThumbEndPoint) ?? '';
            //             // print('GridContentView URL Image: $thumb');
            //
            //             return GestureDetector(
            //               onTap: (){
            //                 context.read<SearchNotifier>().navigateToSeeAllScreen3(context, ref.item1, index, HyppeType.HyppePic);
            //               },
            //               child: Padding(
            //                 padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
            //                 child: dataitem.reportedStatus == 'BLURRED' || dataitem.reportedStatus == 'OWNED'
            //                     ? SensitiveContentProfile(data: dataitem)
            //                     : Stack(
            //                   children: [
            //                     Center(
            //                       child: CustomContentModeratedWidget(
            //                         width: double.infinity,
            //                         height: double.infinity,
            //                         isSale: false,
            //                         isSafe: true, //notifier.postData.data.listPic[index].isSafe,
            //                         thumbnail: thumb,
            //                       ),
            //                     ),
            //                     // SelectableText(notifier.iw tem1?.pics?[index].isApsara ?? false
            //                     //     ? (notifier.user?.pics?[index].mediaThumbEndPoint ?? '')
            //                     //     : System().showUserPicture(notifier.user?.pics?[index].mediaThumbEndPoint) ?? ''),
            //                     (dataitem.saleAmount ?? 0) > 0
            //                         ? const Align(
            //                         alignment: Alignment.topRight,
            //                         child: Padding(
            //                           padding: const EdgeInsets.all(4.0),
            //                           child: CustomIconWidget(
            //                             iconData: "${AssetPath.vectorPath}sale.svg",
            //                             height: 22,
            //                             defaultColor: false,
            //                           ),
            //                         ))
            //                         : Container(),
            //                     (dataitem.certified ?? false) && (dataitem.saleAmount ?? 0) == 0
            //                         ? Align(
            //                         alignment: Alignment.topRight,
            //                         child: Padding(
            //                             padding: const EdgeInsets.all(2.0),
            //                             child: Container(
            //                                 padding: const EdgeInsets.all(4),
            //                                 child: const CustomIconWidget(
            //                                   iconData: '${AssetPath.vectorPath}ownership.svg',
            //                                   defaultColor: false,
            //                                 ))))
            //                         : Container()
            //                   ],
            //                 ),
            //               ),
            //             );
            //           }).toList()
            //       ),
            //     ),
            //     if(ref.item3)
            //       SliverToBoxAdapter(
            //         child: Container(
            //             width: double.infinity,
            //             height: 50,
            //             alignment: Alignment.center,
            //             child: const CustomLoading()),
            //       )
            //   ],
            // );
          }
      ),
    );
  }
}

