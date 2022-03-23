import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_content_moderated_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SelfProfileDiaries extends StatelessWidget {
  const SelfProfileDiaries({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SelfProfileNotifier, Tuple2<UserInfoModel?, int>>(
      selector: (_, select) => Tuple2(select.user, select.diaryCount),
      builder: (_, notifier, __) => notifier.item1 != null
          ? SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  try {
                    return GestureDetector(
                      onTap: () => context.read<SelfProfileNotifier>().navigateToSeeAllScreen(context, index),
                      child: Padding(
                        padding: EdgeInsets.all(2 * SizeConfig.scaleDiagonal),
                        child: CustomContentModeratedWidget(
                            width: double.infinity,
                            height: double.infinity,
                            featureType: FeatureType.diary,
                            isSafe: true,//notifier.postData!.data.listDiary[index].isSafe!,
                            thumbnail: System().showUserPicture(notifier.item1?.diaries?[index].mediaThumbEndPoint)!,
                        ),
                      ),
                    );
                  } catch (e) {
                    print('[DevError] => ${e.toString()}');
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('${AssetPath.pngPath}content-error.png'), fit: BoxFit.fill),
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
