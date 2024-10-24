import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/offline_mode.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';

class SelfProfileVids extends StatelessWidget {
  final ScrollController? scrollController;
  final double? height;
  const SelfProfileVids({Key? key, this.height, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SelfProfileVids');
    return Consumer<SelfProfileNotifier>(builder: (_, notifier, __) {
      return !notifier.isConnectContent
          ? SliverFillRemaining(
              hasScrollBody: false,
              child: OfflineMode(
                function: () {
                  if (!notifier.isConnectContent) {
                    notifier.getDataPerPgage(context);
                  }
                },
              ),
            )
          : notifier.user.vids != null
              ? notifier.user.vids!.isEmpty
                  ? const EmptyWidget()
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          try {
                            if (index == notifier.user.vids?.length) {
                              return Container();
                            }
                            // else if (notifier.scollLoading && notifier.vidHasNext) {
                            //   return const Padding(
                            //     padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                            //     // child: CustomLoading(size: 4),
                            //   );
                            // }
                            print('url image thumb image: ${notifier.user.vids?[index].isApsara} ${notifier.user.vids?[index].mediaThumbEndPoint}');
                            return GestureDetector(
                              onTap: () => context.read<SelfProfileNotifier>().navigateToSeeAllScreen(
                                    context,
                                    index,
                                    const Text(
                                      "Vid",
                                      style: TextStyle(color: kHyppeTextLightPrimary),
                                    ),
                                    scrollController: scrollController,
                                    heightProfile: height,
                                  ),
                              child: Padding(
                                padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                                child: notifier.user.vids?[index].reportedStatus == 'BLURRED' || notifier.user.vids?[index].reportedStatus == 'OWNED'
                                    ? SensitiveContentProfile(data: notifier.user.vids?[index])
                                    : Stack(
                                        children: [
                                          Center(
                                            child: CustomContentModeratedWidget(
                                              width: double.infinity,
                                              height: double.infinity,
                                              featureType: FeatureType.vid,
                                              isSale: false,
                                              isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                              thumbnail: ImageUrl(notifier.user.vids?[index].postID,
                                                  url: (notifier.user.vids?[index].isApsara ?? false)
                                                      ? (notifier.user.vids?[index].mediaThumbEndPoint ?? '')
                                                      : System().showUserPicture(notifier.user.vids?[index].mediaThumbEndPoint) ?? ''),
                                            ),
                                          ),
                                          // SelectableText(notifier.iw tem1?.vids?[index].isApsara ?? false
                                          //     ? (notifier.user?.vids?[index].mediaThumbEndPoint ?? '')
                                          //     : System().showUserPicture(notifier.user?.vids?[index].mediaThumbEndPoint) ?? ''),
                                          (notifier.user.vids?[index].saleAmount ?? 0) > 0
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
                                          (notifier.user.vids?[index].certified ?? false) && (notifier.user.vids?[index].saleAmount ?? 0) == 0
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
                            '[DevError] => ${e.toString()}'.logger();
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: const BoxDecoration(
                                image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
                              ),
                            );
                          }
                        },
                        childCount: notifier.user.vids?.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                    )
              : BothProfileContentShimmer();
    });
    // return Selector<SelfProfileNotifier, Tuple3<UserInfoModel?, int, bool>>(
    //     selector: (_, select) => Tuple3(select.user, select.vidCount, select.vidHasNext),
    //     builder: (_, notifier, __) {
    //       return notifier.item1 != null
    //           ? notifier.item2 == 0
    //               ? const EmptyWidget()
    //               : SliverGrid(
    //                   delegate: SliverChildBuilderDelegate(
    //                     (BuildContext context, int index) {
    //                       try {
    //                         if (index == notifier.item1?.vids?.length) {
    //                           return Container();
    //                         } else if (index == (notifier.item1?.vids?.length ?? 0) + 1 && notifier.item3) {
    //                           return const Padding(
    //                             padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
    //                             child: CustomLoading(size: 4),
    //                           );
    //                         }

    //                         return GestureDetector(
    //                           onTap: () => context.read<SelfProfileNotifier>().navigateToSeeAllScreen(context, index),
    //                           child: Padding(
    //                             padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
    //                             child: notifier.item1?.vids?[index].reportedStatus == 'BLURRED' || notifier.item1?.vids?[index].reportedStatus == 'OWNED'
    //                                 ? SensitiveContentProfile(data: notifier.item1?.vids?[index])
    //                                 : Stack(
    //                                     children: [
    //                                       Center(
    //                                         child: CustomContentModeratedWidget(
    //                                           width: double.infinity,
    //                                           height: double.infinity,
    //                                           featureType: FeatureType.vid,
    //                                           isSafe: true, //notifier.postData.data.listVid[index].isSafe,
    //                                           thumbnail: notifier.item1?.vids?[index].isApsara ?? false
    //                                               ? (notifier.item1?.vids?[index].mediaThumbEndPoint ?? '')
    //                                               : System().showUserPicture(notifier.item1?.vids?[index].mediaThumbEndPoint) ?? '',
    //                                         ),
    //                                       ),
    //                                       // SelectableText(notifier.iw tem1?.vids?[index].isApsara ?? false
    //                                       //     ? (notifier.item1?.vids?[index].mediaThumbEndPoint ?? '')
    //                                       //     : System().showUserPicture(notifier.item1?.vids?[index].mediaThumbEndPoint) ?? ''),
    //                                       (notifier.item1?.vids?[index].saleAmount ?? 0) > 0
    //                                           ? const Align(
    //                                               alignment: Alignment.topRight,
    //                                               child: Padding(
    //                                                 padding: const EdgeInsets.all(2.0),
    //                                                 child: CustomIconWidget(
    //                                                   iconData: "${AssetPath.vectorPath}sale.svg",
    //                                                   height: 15,
    //                                                   defaultColor: false,
    //                                                 ),
    //                                               ))
    //                                           : Container(),
    //                                       (notifier.item1?.vids?[index].certified ?? false) && (notifier.item1?.vids?[index].saleAmount ?? 0) == 0
    //                                           ? Align(
    //                                               alignment: Alignment.topRight,
    //                                               child: Padding(
    //                                                   padding: const EdgeInsets.all(2.0),
    //                                                   child: Container(
    //                                                       padding: const EdgeInsets.all(4),
    //                                                       decoration: BoxDecoration(
    //                                                         borderRadius: BorderRadius.circular(4),
    //                                                         color: Colors.black.withOpacity(0.3),
    //                                                       ),
    //                                                       child: const CustomIconWidget(
    //                                                         iconData: '${AssetPath.vectorPath}ownership.svg',
    //                                                         defaultColor: false,
    //                                                       ))))
    //                                           : Container()
    //                                     ],
    //                                   ),
    //                           ),
    //                         );
    //                       } catch (e) {
    //                         '[DevError] => ${e.toString()}'.logger();
    //                         return Container(
    //                           width: double.infinity,
    //                           height: double.infinity,
    //                           decoration: const BoxDecoration(
    //                             image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
    //                           ),
    //                         );
    //                       }
    //                     },
    //                     childCount: notifier.item2,
    //                   ),
    //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    //                 )
    //           : BothProfileContentShimmer();
    //     });
  }
}
