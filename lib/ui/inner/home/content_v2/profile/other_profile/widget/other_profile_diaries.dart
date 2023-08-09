import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/empty_other_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:measured_size/measured_size.dart';

import '../../../../../../constant/widget/custom_loading.dart';

class OtherProfileDiaries extends StatelessWidget {
  final List<ContentData>? diaries;
  final ScrollController? scrollController;
  final double? height;
  const OtherProfileDiaries({Key? key, this.diaries, this.scrollController, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfileDiaries');
    return Consumer<OtherProfileNotifier>(
      builder: (_, notifier, __) => notifier.manyUser.isEmpty
          ? const EmptyOtherWidget()
          : (notifier.manyUser.last.diaries?.isEmpty ?? [].isEmpty)
              ? const EmptyOtherWidget()
              // ? SliverFillRemaining(
              //     child: Column(
              //       children: [
              //         Text("${notifier.manyUser.last.pics}"),
              //         Text("${notifier.manyUser.last.diaries}"),
              //         Text("${notifier.manyUser}"),
              //       ],
              //     ),
              //   )
              : SliverGrid.count(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                  childAspectRatio: 0.67,
                  children: List.generate(notifier.manyUser.last.diaries?.length ?? 0, (index) {
                    try {
                      if (index == notifier.manyUser.last.diaries?.length) {
                        return Container();
                      } else if (index == (notifier.manyUser.last.diaries?.length ?? 0) + 1) {
                        return const Padding(
                          padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                          child: CustomLoading(size: 4),
                        );
                      }
                      return GestureDetector(
                        onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(
                              context,
                              index,
                              data: notifier.manyUser.last.diaries,
                              title: const Text(
                                "Diary",
                                style: TextStyle(color: kHyppeTextLightPrimary),
                              ),
                              scrollController: scrollController,
                              heightProfile: height,
                            ),
                        child: Padding(
                          padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                          child: notifier.manyUser.last.diaries?[index].reportedStatus == 'BLURRED'
                              ? SensitiveContentProfile(data: notifier.manyUser.last.diaries?[index])
                              : Stack(
                                  children: [
                                    Center(
                                      child: CustomContentModeratedWidget(
                                        width: double.infinity,
                                        height: double.infinity,
                                        featureType: FeatureType.pic,
                                        isSafe: true, //notifier.postData.data.listDiary[index].isSafe,
                                        isSale: false,
                                        thumbnail: ImageUrl(notifier.manyUser.last.diaries?[index].postID,
                                            url: (notifier.manyUser.last.diaries?[index].isApsara ?? false)
                                                ? (notifier.manyUser.last.diaries?[index].mediaThumbEndPoint ?? '')
                                                : System().showUserPicture(notifier.manyUser.last.diaries?[index].mediaThumbEndPoint) ?? ''),
                                      ),
                                    ),
                                    (notifier.manyUser.last.diaries?[index].saleAmount ?? 0) > 0
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
                                    (notifier.manyUser.last.diaries?[index].certified ?? false) && (notifier.manyUser.last.diaries?[index].saleAmount ?? 0) == 0
                                        ? Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(4),
                                                      color: Colors.black.withOpacity(0.3),
                                                    ),
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
                  }),
                  // delegate: SliverChildBuilderDelegate(
                  //   (BuildContext context, int index) {},
                  //   childCount: notifier.item2,
                  // ),
                  // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                ),
    );
    // : BothProfileContentShimmer();

    //old
    // return Selector<OtherProfileNotifier, Tuple3<UserInfoModel?, int, bool>>(
    //   selector: (_, select) => Tuple3(select.user, select.diaryCount, select.diaryHasNext),
    //   builder: (_, notifier, __) => notifier.item1 != null
    //       ? (diaries?.isEmpty ?? [].isEmpty)
    //           ? const EmptyOtherWidget()
    //           : SliverGrid.count(
    //               crossAxisSpacing: 0,
    //               mainAxisSpacing: 0,
    //               crossAxisCount: 3,
    //               childAspectRatio: 0.67,
    //               children: List.generate(diaries?.length ?? 0, (index) {
    //                 try {
    //                   if (index == diaries?.length) {
    //                     return Container();
    //                   } else if (index == (diaries?.length ?? 0) + 1 && notifier.item3) {
    //                     return const Padding(
    //                       padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
    //                       child: CustomLoading(size: 4),
    //                     );
    //                   }
    //                   return GestureDetector(
    //                     onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(
    //                           context,
    //                           index,
    //                           data: diaries,
    //                           title: const Text(
    //                             "Diary",
    //                             style: TextStyle(color: kHyppeTextLightPrimary),
    //                           ),
    //                         ),
    //                     child: Padding(
    //                       padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
    //                       child: diaries?[index].reportedStatus == 'BLURRED'
    //                           ? SensitiveContentProfile(data: diaries?[index])
    //                           : Stack(
    //                               children: [
    //                                 Center(
    //                                   child: CustomContentModeratedWidget(
    //                                     width: double.infinity,
    //                                     height: double.infinity,
    //                                     featureType: FeatureType.diary,
    //                                     isSafe: true, //notifier.postData.data.listDiary[index].isSafe,
    //                                     isSale: false,
    //                                     thumbnail: ImageUrl(diaries?[index].postID,
    //                                         url: (diaries?[index].isApsara ?? false) ? (diaries?[index].mediaThumbEndPoint ?? '') : System().showUserPicture(diaries?[index].mediaThumbEndPoint) ?? ''),
    //                                   ),
    //                                 ),
    //                                 (diaries?[index].saleAmount ?? 0) > 0
    //                                     ? const Align(
    //                                         alignment: Alignment.topRight,
    //                                         child: Padding(
    //                                           padding: EdgeInsets.all(4.0),
    //                                           child: CustomIconWidget(
    //                                             iconData: "${AssetPath.vectorPath}sale.svg",
    //                                             height: 22,
    //                                             defaultColor: false,
    //                                           ),
    //                                         ))
    //                                     : Container(),
    //                                 (diaries?[index].certified ?? false) && (diaries?[index].saleAmount ?? 0) == 0
    //                                     ? Align(
    //                                         alignment: Alignment.topRight,
    //                                         child: Padding(
    //                                             padding: const EdgeInsets.all(2.0),
    //                                             child: Container(
    //                                                 padding: const EdgeInsets.all(4),
    //                                                 decoration: BoxDecoration(
    //                                                   borderRadius: BorderRadius.circular(4),
    //                                                   color: Colors.black.withOpacity(0.3),
    //                                                 ),
    //                                                 child: const CustomIconWidget(
    //                                                   iconData: '${AssetPath.vectorPath}ownership.svg',
    //                                                   defaultColor: false,
    //                                                 ))))
    //                                     : Container()
    //                               ],
    //                             ),
    //                     ),
    //                   );
    //                 } catch (e) {
    //                   print('[DevError] => ${e.toString()}');
    //                   return Container(
    //                     width: double.infinity,
    //                     height: double.infinity,
    //                     decoration: const BoxDecoration(
    //                       image: DecorationImage(image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
    //                     ),
    //                   );
    //                 }
    //               }),
    //               // delegate: SliverChildBuilderDelegate(
    //               //   (BuildContext context, int index) {},
    //               //   childCount: notifier.item2,
    //               // ),
    //               // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    //             )
    //       : BothProfileContentShimmer(),
    // );
  }
}
