import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Profile');
    // var notifier = context.select((SelfProfileNotifier value) => Tuple2(value.user, value.user.profile?.avatar?.mediaEndpoint));
    // final myPicture = context.select((SelfProfileNotifier value) => value.user.profile?.avatar?.mediaEndpoint);
    final notifier = Provider.of<HomeNotifier>(context);
    // 'showUserPicture 1 : ${notifier.profileImage}'.logger();
    return CustomProfileImage(
      cacheKey: notifier.profileImageKey,
      width: 36,
      height: 36,
      following: true,
      imageUrl: System().showUserPicture(notifier.profileImage) ?? '',
      // badge: notifier.profileBadge,
    );

    // return notifier.item1 != null
    //     ? Container(
    //         width: 50,
    //         child: CustomTextButton(
    //           style: ButtonStyle(alignment: Alignment.centerRight, padding: MaterialStateProperty.all(EdgeInsets.only(left: 0.0))),
    //           // onPressed: () => context.read<HomeNotifier>().navigateToProfilePage(context),
    //           onPressed: () {},
    //           child: CustomProfileImage(
    //             width: 26,
    //             height: 26,
    //             following: true,
    //             imageUrl: '${notifier.item2}$VERYBIG',
    //           ),
    //         ),
    //       )
    //     : CustomShimmer(
    //         height: 26,
    //         width: 26,
    //         boxShape: BoxShape.circle,
    //       );
  }
}
