import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var notifier = context.select((SelfProfileNotifier value) => Tuple2(value.user, value.user.profile?.avatar?.mediaEndpoint));

    return SizedBox(
      width: 50,
      child: CustomTextButton(
        style: ButtonStyle(alignment: Alignment.centerRight, padding: MaterialStateProperty.all(const EdgeInsets.only(left: 0.0))),
        onPressed: () => context.read<HomeNotifier>().navigateToProfilePage(context),
        child: CustomProfileImage(
          width: 26,
          height: 26,
          following: true,
          imageUrl: System().showUserPicture(notifier.item2 ?? ''),
        ),
      ),
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
