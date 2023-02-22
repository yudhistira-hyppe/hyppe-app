import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/sensitive_content.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../../../constant/widget/custom_loading.dart';

class OtherProfilePics extends StatelessWidget {
  const OtherProfilePics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<OtherProfileNotifier, Tuple3<UserInfoModel?, int, bool>>(
      selector: (_, select) => Tuple3(select.user, select.picCount, select.picHasNext),
      builder: (_, notifier, __) => notifier.item1 != null
          ? SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  try {
                    if (index == notifier.item1?.pics?.length) {
                      return Container();
                    } else if (index == (notifier.item1?.pics?.length ?? 0) + 1 && notifier.item3) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 40.0, right: 30.0, bottom: 40.0),
                        child: CustomLoading(size: 4),
                      );
                    }
                    return GestureDetector(
                      onTap: () => context.read<OtherProfileNotifier>().navigateToSeeAllScreen(context, index),
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: notifier.item1?.pics?[index].reportedStatus == 'BLURRED'
                            ? SensitiveContentProfile(data: notifier.item1?.pics?[index])
                            : Stack(
                                children: [
                                  Center(
                                    child: CustomContentModeratedWidget(
                                      width: double.infinity,
                                      height: double.infinity,
                                      isSale: false,
                                      isSafe: true, //notifier.postData.data.listPic[index].isSafe,
                                      thumbnail: (notifier.item1?.pics?[index].isApsara ?? false)
                                          ? (notifier.item1?.pics?[index].mediaThumbEndPoint ?? '')
                                          : System().showUserPicture(notifier.item1?.pics?[index].mediaEndpoint) ?? '',
                                    ),
                                  ),
                                  (notifier.item1?.pics?[index].saleAmount ?? 0) > 0
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
                                  (notifier.item1?.pics?[index].certified ?? false) && (notifier.item1?.pics?[index].saleAmount ?? 0) == 0
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
                childCount: notifier.item2,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            )
          : BothProfileContentShimmer(),
    );
  }
}
