import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/empty_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

class SelfProfileDiaries extends StatelessWidget {
  const SelfProfileDiaries({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SelfProfileDiaries');
    return Consumer<SelfProfileNotifier>(builder: (_, notifier, __) {
      return notifier.user.diaries != null
          ? notifier.user.diaries!.isEmpty
              ? const EmptyWidget()
              : SliverGrid.count(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                  childAspectRatio: 0.67,
                  children: List.generate(
                    notifier.user.diaries?.length ?? 0,
                    (index) {
                      try {
                        if (index == notifier.user.diaries?.length) {
                          return Container();
                        }
                        // else if (notifier.scollLoading && notifier.vidHasNext) {
                        //   return const Padding(
                        //     padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                        //     // child: CustomLoading(size: 4),
                        //   );
                        // }

                        return GestureDetector(
                          onTap: () => context.read<SelfProfileNotifier>().navigateToSeeAllScreen(
                              context,
                              index,
                              const Text(
                                "Diary",
                                style: TextStyle(color: kHyppeTextLightPrimary),
                              )),
                          child: Padding(
                            padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                            child: notifier.user.diaries?[index].reportedStatus == 'BLURRED' || notifier.user.diaries?[index].reportedStatus == 'OWNED'
                                ? SensitiveContentProfile(data: notifier.user.diaries?[index])
                                : Stack(
                                    children: [
                                      Center(
                                        child: CustomContentModeratedWidget(
                                          width: double.infinity,
                                          height: double.infinity,
                                          featureType: FeatureType.vid,
                                          isSale: false,
                                          isSafe: true, //notifier.postData.data.listVid[index].isSafe,
                                          thumbnail: ImageUrl(notifier.user.diaries?[index].postID,
                                              url: (notifier.user.diaries?[index].isApsara ?? false)
                                                  ? (notifier.user.diaries?[index].mediaThumbEndPoint ?? '')
                                                  : System().showUserPicture(notifier.user.diaries?[index].mediaThumbEndPoint) ?? ''),
                                        ),
                                      ),
                                      // SelectableText(notifier.iw tem1?.diaries?[index].isApsara ?? false
                                      //     ? (notifier.user?.diaries?[index].mediaThumbEndPoint ?? '')
                                      //     : System().showUserPicture(notifier.user?.diaries?[index].mediaThumbEndPoint) ?? ''),
                                      (notifier.user.diaries?[index].saleAmount ?? 0) > 0
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
                                      (notifier.user.diaries?[index].certified ?? false) && (notifier.user.diaries?[index].saleAmount ?? 0) == 0
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
                        // '[DevError] => ${e.toString()}'.logger();
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
                          ),
                        );
                      }
                    },
                    // delegate: SliverChildBuilderDelegate(
                    //   (BuildContext context, int index) {

                    //   },
                    //   childCount: notifier.user.diaries?.length,
                    // ),
                    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  ))
          : BothProfileContentShimmer();
    });

    // return Selector<SelfProfileNotifier, Tuple3<UserInfoModel?, int, bool>>(
    //   selector: (_, select) => Tuple3(select.user, select.diaryCount, select.diaryHasNext),
    //   builder: (_, notifier, __) => notifier.item1 != null
    //       ? notifier.item2 == 0
    //           ? const EmptyWidget()
    //           : SliverGrid(
    //               delegate: SliverChildBuilderDelegate(
    //                 (BuildContext context, int index) {
    //                   try {
    //                     if (index == notifier.item1?.diaries?.length) {
    //                       return Container();
    //                     } else if (index == (notifier.item1?.diaries?.length ?? 0) + 1 && notifier.item3) {
    //                       return const Padding(
    //                         padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
    //                         child: CustomLoading(size: 4),
    //                       );
    //                     }
    //                     return GestureDetector(
    //                       onTap: () => context.read<SelfProfileNotifier>().navigateToSeeAllScreen(context, index),
    //                       child: Padding(
    //                         padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
    //                         child: notifier.item1?.diaries?[index].reportedStatus == 'BLURRED' || notifier.item1?.diaries?[index].reportedStatus == 'OWNED'
    //                             ? SensitiveContentProfile(data: notifier.item1?.diaries?[index])
    //                             : Stack(
    //                                 children: [
    //                                   Center(
    //                                     child: CustomContentModeratedWidget(
    //                                       width: double.infinity,
    //                                       height: double.infinity,
    //                                       featureType: FeatureType.diary,
    //                                       isSale: false,
    //                                       isSafe: true, //notifier.postData.data.listDiary[index].isSafe,
    //                                       thumbnail: (notifier.item1?.diaries?[index].isApsara ?? false)
    //                                           ? (notifier.item1?.diaries?[index].mediaThumbEndPoint ?? '')
    //                                           : System().showUserPicture(notifier.item1?.diaries?[index].mediaThumbEndPoint) ?? '',
    //                                     ),
    //                                   ),
    //                                   (notifier.item1?.diaries?[index].saleAmount ?? 0) > 0
    //                                       ? const Align(
    //                                           alignment: Alignment.topRight,
    //                                           child: Padding(
    //                                             padding: const EdgeInsets.all(2.0),
    //                                             child: CustomIconWidget(
    //                                               iconData: "${AssetPath.vectorPath}sale.svg",
    //                                               height: 15,
    //                                               defaultColor: false,
    //                                             ),
    //                                           ))
    //                                       : Container(),
    //                                   (notifier.item1?.diaries?[index].certified ?? false) && (notifier.item1?.diaries?[index].saleAmount ?? 0) == 0
    //                                       ? Align(
    //                                           alignment: Alignment.topRight,
    //                                           child: Padding(
    //                                               padding: const EdgeInsets.all(2.0),
    //                                               child: Container(
    //                                                   padding: const EdgeInsets.all(4),
    //                                                   decoration: BoxDecoration(
    //                                                     borderRadius: BorderRadius.circular(4),
    //                                                     color: Colors.black.withOpacity(0.3),
    //                                                   ),
    //                                                   child: const CustomIconWidget(
    //                                                     iconData: '${AssetPath.vectorPath}ownership.svg',
    //                                                     defaultColor: false,
    //                                                   ))))
    //                                       : Container(),
    //                                 ],
    //                               ),
    //                       ),
    //                     );
    //                   } catch (e) {
    //                     // print('[DevError] => ${e.toString()}');
    //                     return Container(
    //                       width: double.infinity,
    //                       height: double.infinity,
    //                       decoration: const BoxDecoration(
    //                         image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
    //                       ),
    //                     );
    //                   }
    //                 },
    //                 childCount: notifier.item2,
    //               ),
    //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    //             )
    //       : BothProfileContentShimmer(),
    // );
  }
}
