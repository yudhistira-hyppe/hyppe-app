import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_top.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_top_shimmer.dart';
import 'package:provider/provider.dart';

import 'package:measured_size/measured_size.dart';

class OtherProfileScreen extends StatefulWidget {
  final OtherProfileArgument arguments;
  const OtherProfileScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  _OtherProfileScreenState createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  int heightProfileCard = 0;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfileScreen');
    print('other profile');
    final notifier = Provider.of<OtherProfileNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () => notifier.initialOtherProfile(context, argument: widget.arguments));
    _scrollController.addListener(() => notifier.onScrollListener(context, _scrollController));
    System().disposeBlock();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    System().disposeBlock();
    // final notifier = context.read<OtherProfileNotifier>();
    // Future.delayed(const Duration(milliseconds: 500), () {
    // var jumpTo = heightProfileCard + notifier.heightIndex;
    // print("---------- $jumpTo");
    // print("---------- $heightProfileCard");
    // print("---------- ${notifier.heightIndex}");
    // _scrollController.jumpTo(jumpTo.toDouble());
    // });

    super.didPopNext();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<OtherProfileNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.onExit();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => notifier.onExit(),
                        icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                      ),
                      CustomTextWidget(
                        textToDisplay: notifier.displayUserName(),
                        textAlign: TextAlign.start,
                        textStyle: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}more.svg"),
                    onPressed: () => ShowBottomSheet.onShowReportProfile(context, userID: notifier.userID),
                  ),
                ],
              ),
            ),
          ),
          body: RefreshIndicator(
            key: _globalKey,
            strokeWidth: 2.0,
            color: Colors.purple,
            onRefresh: () async {
              await notifier.initialOtherProfile(context, refresh: true);
            },
            child: CustomScrollView(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // SliverAppBar(
                //   pinned: false,
                //   stretch: false,
                //   elevation: 0.0,
                //   floating: false,
                //   automaticallyImplyLeading: false,
                //   expandedHeight: (200 * SizeConfig.scaleDiagonal) + 46,
                //   backgroundColor: Theme.of(context).colorScheme.background,
                //   flexibleSpace: FlexibleSpaceBar(
                //     titlePadding: EdgeInsets.zero,
                //     background: notifier.user.profile != null
                //         ? notifier.statusFollowing == StatusFollowing.following
                //             ? const OtherProfileTop()
                //             : const OtherProfileTop()
                //         : BothProfileTopShimmer(),
                //   ),
                // ),
                SliverToBoxAdapter(
                  child: Container(
                    child: notifier.user.profile != null
                        ? notifier.statusFollowing == StatusFollowing.following
                            ? const OtherProfileTop()
                            : const OtherProfileTop()
                        : BothProfileTopShimmer(),
                  ),
                ),
                SliverAppBar(
                  pinned: true,
                  flexibleSpace: OtherProfileBottom(),
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.background,
                ),
                if (notifier.user.profile != null && notifier.statusFollowing == StatusFollowing.following)
                  notifier.optionButton()
                // else if (notifier.peopleProfile?.userDetail?.data?.isPrivate ?? false)
                //     SliverList(delegate: SliverChildListDelegate([PrivateAccount()]))
                else
                  notifier.optionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
