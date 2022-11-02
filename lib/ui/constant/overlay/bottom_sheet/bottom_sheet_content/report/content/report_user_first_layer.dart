import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/report/widget/build_list_tile.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:hyppe/ux/routing.dart';
// import 'package:hyppe/core/services/system.dart';
// import 'package:hyppe/core/constants/enum.dart';
// import 'package:hyppe/core/bloc/follow/bloc.dart';
// import 'package:hyppe/core/bloc/follow/state.dart';
// import 'package:hyppe/core/constants/shared_preference_keys.dart';
// import 'package:hyppe/core/services/shared_preference.dart';
// import 'package:hyppe/core/models/collection/follow/follow.dart';
// import 'package:hyppe/ui/inner/home/content/profile/notifier.dart';

class ReportUserFirstLayer extends StatelessWidget {
  final String? userID;
  const ReportUserFirstLayer({this.userID});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          CustomTextWidget(
            // textToDisplay: notifier.peopleProfile != null ? notifier.peopleProfile.profileOverviewData!.userOverviewData.username : "",
            textToDisplay: "dummy_user",
            textStyle: Theme.of(context).textTheme.subtitle1!.apply(color: const Color(0xffEEEEEE)),
          ),
          // notifier.statusFollowing != StatusFollowing.following
          //     ? SizedBox.shrink()
          //     : BuildListTile(
          //         onTap: () => _unFollowUser(context),
          //         icon: "${AssetPath.vectorPath}close.svg",
          //         title: notifier.translate.unfollow ?? '',
          //       ),
          const SizedBox.shrink(),
          BuildListTile(
            icon: "${AssetPath.vectorPath}report.svg",
            title: notifier.translate.reportOrBlock ?? '',
            onTap: () => context.read<ReportNotifier>().screen = true,
          ),
        ],
      ),
    );
  }

  // _unFollowUser(BuildContext context) async {
  //   final notifier = Provider.of<ProfileNotifier>(context, listen: false);
  //   String? myID = SharedPreference().readStorage(SpKeys.userID);
  //   final notifier2 = Provider.of<FollowBloc>(context, listen: false);
  //   await notifier2.followUserBloc(context,
  //       data: FollowUser(
  //         fUserID: userID,
  //         sts: System().postStatusFollow(StatusFollowing.following),
  //         userID: myID,
  //       ));
  //   final fetch = notifier2.followFetch;
  //   if (fetch.followState == FollowState.followUserSuccess) {
  //     notifier.statusFollowing = StatusFollowing.rejected;
  //     Routing().moveBack();
  //   }
  // }
}
