import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/empty_other_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import '../../../../../../constant/widget/custom_loading.dart';

class OtherProfileVids extends StatelessWidget {
  final List<ContentData>? vids;
  final ScrollController? scrollController;
  final double? height;
  const OtherProfileVids({Key? key, this.vids, this.scrollController, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfileVids');
    return Consumer<OtherProfileNotifier>(
      builder: (_, notifier, __) => notifier.manyUser.isEmpty
          ? Container()
          : (notifier.manyUser.last.vids?.isEmpty ?? [].isEmpty)
              ? const EmptyOtherWidget()
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      try {
                        if (index == notifier.manyUser.last.vids?.length) {
                          return Container();
                        } else if (index == (notifier.manyUser.last.vids?.length ?? 0) + 1) {
                          return const Padding(
                            padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                            child: CustomLoading(size: 4),
                          );
                        }
                        return GestureDetector(
                          onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(
                                context,
                                index,
                                data: notifier.manyUser.last.vids,
                                title: const Text(
                                  "Vid",
                                  style: TextStyle(color: kHyppeTextLightPrimary),
                                ),
                                scrollController: scrollController,
                                heightProfile: height,
                              ),
                          child: Padding(
                            padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                            child: notifier.manyUser.last.vids?[index].reportedStatus == 'BLURRED'
                                ? SensitiveContentProfile(data: notifier.manyUser.last.vids?[index])
                                : Stack(
                                    children: [
                                      Center(
                                        child: CustomContentModeratedWidget(
                                          width: double.infinity,
                                          height: double.infinity,
                                          isSale: false,
                                          featureType: FeatureType.vid,
                                          isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                          thumbnail: ImageUrl(notifier.manyUser.last.vids?[index].postID,
                                              url: (notifier.manyUser.last.vids?[index].isApsara ?? false)
                                                  ? (notifier.manyUser.last.vids?[index].mediaThumbEndPoint ?? '')
                                                  : System().showUserPicture(notifier.manyUser.last.vids?[index].mediaThumbEndPoint) ?? ''),
                                        ),
                                      ),
                                      (notifier.manyUser.last.vids?[index].saleAmount ?? 0) > 0
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
                                      (notifier.manyUser.last.vids?[index].certified ?? false) && (notifier.manyUser.last.vids?[index].saleAmount ?? 0) == 0
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
                    childCount: notifier.manyUser.last.vids?.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                ),
    );

    // return Selector<OtherProfileNotifier, Tuple3<UserInfoModel?, int, bool>>(
    //   selector: (_, select) => Tuple3(select.user, select.vidCount, select.vidHasNext),
    //   builder: (_, notifier, __) => notifier.item1 != null
    //       ? (vids?.isEmpty ?? [].isEmpty)
    //           ? const EmptyOtherWidget()
    //           : SliverGrid(
    //               delegate: SliverChildBuilderDelegate(
    //                 (BuildContext context, int index) {
    //                   try {
    //                     if (index == vids?.length) {
    //                       return Container();
    //                     } else if (index == (vids?.length ?? 0) + 1 && notifier.item3) {
    //                       return const Padding(
    //                         padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
    //                         child: CustomLoading(size: 4),
    //                       );
    //                     }
    //                     return GestureDetector(
    //                       onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(
    //                             context,
    //                             index,
    //                             data: vids,
    //                             title: const Text(
    //                               "Vid",
    //                               style: TextStyle(color: kHyppeTextLightPrimary),
    //                             ),
    //                           ),
    //                       child: Padding(
    //                         padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
    //                         child: vids?[index].reportedStatus == 'BLURRED'
    //                             ? SensitiveContentProfile(data: vids?[index])
    //                             : Stack(
    //                                 children: [
    //                                   Center(
    //                                     child: CustomContentModeratedWidget(
    //                                       width: double.infinity,
    //                                       height: double.infinity,
    //                                       isSale: false,
    //                                       featureType: FeatureType.vid,
    //                                       isSafe: true, //notifier.postData.data.listVid[index].isSafe,
    //                                       thumbnail: ImageUrl(vids?[index].postID,
    //                                           url: (vids?[index].isApsara ?? false) ? (vids?[index].mediaThumbEndPoint ?? '') : System().showUserPicture(vids?[index].mediaThumbEndPoint) ?? ''),
    //                                     ),
    //                                   ),
    //                                   (vids?[index].saleAmount ?? 0) > 0
    //                                       ? const Align(
    //                                           alignment: Alignment.topRight,
    //                                           child: Padding(
    //                                             padding: EdgeInsets.all(4.0),
    //                                             child: CustomIconWidget(
    //                                               iconData: "${AssetPath.vectorPath}sale.svg",
    //                                               height: 22,
    //                                               defaultColor: false,
    //                                             ),
    //                                           ))
    //                                       : Container(),
    //                                   (vids?[index].certified ?? false) && (vids?[index].saleAmount ?? 0) == 0
    //                                       ? Align(
    //                                           alignment: Alignment.topRight,
    //                                           child: Padding(
    //                                               padding: const EdgeInsets.all(2.0),
    //                                               child: Container(
    //                                                   padding: const EdgeInsets.all(4),
    //                                                   child: const CustomIconWidget(
    //                                                     iconData: '${AssetPath.vectorPath}ownership.svg',
    //                                                     defaultColor: false,
    //                                                   ))))
    //                                       : Container()
    //                                 ],
    //                               ),
    //                       ),
    //                     );
    //                   } catch (e) {
    //                     print('[DevError] => ${e.toString()}');
    //                     return Container(
    //                       width: double.infinity,
    //                       height: double.infinity,
    //                       decoration: const BoxDecoration(
    //                         image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
    //                       ),
    //                     );
    //                   }
    //                 },
    //                 childCount: vids?.length,
    //               ),
    //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    //             )
    //       : BothProfileContentShimmer(),
    // );
  }
}
