import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/empty_other_page.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
// import 'package:measured_size/measured_size.dart';
import '../../../../../../constant/widget/custom_loading.dart';

class OtherProfilePics extends StatelessWidget {
  final List<ContentData>? pics;
  final ScrollController? scrollController;
  final double? height;

  const OtherProfilePics({Key? key, this.pics, this.scrollController, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfilePics');
    return (pics?.isEmpty ?? [].isEmpty)
        ? const EmptyOtherWidget()
        : Consumer<OtherProfileNotifier>(
            builder: (_, notifier, __) => notifier.manyUser.isEmpty
                ? Container()
                : (notifier.manyUser.last.pics?.isEmpty ?? [].isEmpty)
                    ? const EmptyOtherWidget()
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            try {
                              if (index == notifier.manyUser.last.pics?.length) {
                                return Container();
                              } else if (index == (notifier.manyUser.last.pics?.length ?? 0) + 1) {
                                return const Padding(
                                  padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                                  child: CustomLoading(size: 4),
                                );
                              }
                              return GestureDetector(
                                onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(
                                      context,
                                      index,
                                      data: notifier.manyUser.last.pics,
                                      title: const Text(
                                        "Pic",
                                        style: TextStyle(color: kHyppeTextLightPrimary),
                                      ),
                                      scrollController: scrollController,
                                      heightProfile: height,
                                    ),
                                child: Padding(
                                  padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                                  child: notifier.manyUser.last.pics?[index].reportedStatus == 'BLURRED'
                                      ? SensitiveContentProfile(data: notifier.manyUser.last.pics?[index])
                                      : Stack(
                                          children: [
                                            Center(
                                              child: CustomContentModeratedWidget(
                                                width: double.infinity,
                                                height: double.infinity,
                                                isSale: false,
                                                isSafe: true, //notifier.postData.data.listPic[index].isSafe,
                                                thumbnail: ImageUrl(notifier.manyUser.last.pics?[index].postID,
                                                    url: (notifier.manyUser.last.pics?[index].isApsara ?? false)
                                                        ? (notifier.manyUser.last.pics?[index].mediaThumbEndPoint ?? '')
                                                        : System().showUserPicture(notifier.manyUser.last.pics?[index].mediaThumbEndPoint) ?? ''),
                                              ),
                                            ),
                                            (pics?[index].saleAmount ?? 0) > 0
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
                                            (pics?[index].certified ?? false) && (pics?[index].saleAmount ?? 0) == 0
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
                          childCount: notifier.manyUser.last.pics?.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      ),
          );
    // : BothProfileContentShimmer();

    //return Selector<OtherProfileNotifier, Tuple3<UserInfoModel?, int, bool>>(
    //   selector: (_, select) => Tuple3(select.user, select.picCount, select.picHasNext),
    //   builder: (_, notifier, __) => notifier.item1 != null
    //       ? (pics?.isEmpty ?? [].isEmpty)
    //           ? const EmptyOtherWidget()
    //           : SliverGrid(
    //               delegate: SliverChildBuilderDelegate(
    //                 (BuildContext context, int index) {
    //                   try {
    //                     if (index == pics?.length) {
    //                       return Container();
    //                     } else if (index == (pics?.length ?? 0) + 1 && notifier.item3) {
    //                       return const Padding(
    //                         padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
    //                         child: CustomLoading(size: 4),
    //                       );
    //                     }
    //                     return GestureDetector(
    //                       onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(
    //                             context,
    //                             index,
    //                             data: pics,
    //                             title: const Text(
    //                               "Pic",
    //                               style: TextStyle(color: kHyppeTextLightPrimary),
    //                             ),
    //                           ),
    //                       child: Padding(
    //                         padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
    //                         child: pics?[index].reportedStatus == 'BLURRED'
    //                             ? SensitiveContentProfile(data: pics?[index])
    //                             : Stack(
    //                                 children: [
    //                                   Center(
    //                                     child: CustomContentModeratedWidget(
    //                                       width: double.infinity,
    //                                       height: double.infinity,
    //                                       isSale: false,
    //                                       isSafe: true, //notifier.postData.data.listPic[index].isSafe,
    //                                       thumbnail: ImageUrl(pics?[index].postID,
    //                                           url: (pics?[index].isApsara ?? false) ? (pics?[index].mediaThumbEndPoint ?? '') : System().showUserPicture(pics?[index].mediaEndpoint) ?? ''),
    //                                     ),
    //                                   ),
    //                                   (pics?[index].saleAmount ?? 0) > 0
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
    //                                   (pics?[index].certified ?? false) && (pics?[index].saleAmount ?? 0) == 0
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
    //                 childCount: pics?.length,
    //               ),
    //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    //             )
    //       : BothProfileContentShimmer(),
    // );
  }
}
