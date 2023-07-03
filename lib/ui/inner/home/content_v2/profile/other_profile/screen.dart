import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/scheduler.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/models/combination_v2/get_user_profile.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_diaries.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_pics.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_top.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/other_profile/widget/other_profile_vids.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/offline_mode.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_top_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/notifier.dart';
import 'package:provider/provider.dart';

import 'package:measured_size/measured_size.dart';

class OtherProfileScreen extends StatefulWidget {
  final OtherProfileArgument arguments;
  const OtherProfileScreen({Key? key, required this.arguments}) : super(key: key);

  @override
  State<OtherProfileScreen> createState() => OtherProfileScreenState();
}

class OtherProfileScreenState extends State<OtherProfileScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();

  double heightProfileCard = 0;
  UserInfoModel? userData;
  Map<String, List<ContentData>>? otherStoryGroup;
  bool isloading = false;

  void scroll() {
    print("==================hihihi==============");
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'OtherProfileScreen');
    print('other profile');
    final notifier = Provider.of<OtherProfileNotifier>(context, listen: false);
    final sn = Provider.of<PreviewStoriesNotifier>(context, listen: false);
    notifier.user.profile = null;
    isloading = true;
    Future.delayed(Duration.zero, () async {
      notifier.pageIndex = 0;
      await notifier.initialOtherProfile(context, argument: widget.arguments).then((value) => isloading = false);
      userData = notifier.user;
      otherStoryGroup = sn.otherStoryGroup;
    });
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
    print("========== golbalToOther $golbalToOther");

    if (golbalToOther > 1) {
      setState(() {
        isloading = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isloading = false;
        });
        golbalToOther--;
      });
    }

    if (globalAfterReport) {
      setState(() {
        isloading = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          isloading = false;
        });
        globalAfterReport = false;
      });
    }

    // setState(() {});

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

  Widget optionButton(bool isLoading, int index, double height) {
    List pages = [
      !isLoading
          ? OtherProfilePics(
              pics: userData?.pics ?? [],
              scrollController: _scrollController,
              height: height,
            )
          : BothProfileContentShimmer(),
      !isLoading
          ? OtherProfileDiaries(
              diaries: userData?.diaries ?? [],
              scrollController: _scrollController,
              height: height,
            )
          : BothProfileContentShimmer(),
      !isLoading
          ? OtherProfileVids(
              vids: userData?.vids ?? [],
              scrollController: _scrollController,
              height: height,
            )
          : BothProfileContentShimmer(),
    ];
    return pages[index];
  }

  void changeVal(String type, List<ContentData>? data) {
    switch (type) {
      case 'pict':
        userData?.pics = data;
        break;
      case 'diary':
        userData?.diaries = data;
        break;
      default:
        userData?.vids = data;
    }
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
                        // textToDisplay: notifier.displayUserName(),
                        textToDisplay: userData?.profile?.username == null ? '' : "@${userData?.profile?.username}",
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
              await notifier.initialOtherProfile(context, refresh: true, argument: widget.arguments);
              final sn = Provider.of<PreviewStoriesNotifier>(context, listen: false);
              otherStoryGroup = sn.otherStoryGroup;
            },
            child: isloading
                ? CustomScrollView(
                    slivers: [SliverToBoxAdapter(child: BothProfileTopShimmer()), BothProfileContentShimmer()],
                  )
                : !notifier.isConnect && notifier.user.profile == null
                    ? OfflineMode(
                        function: () async {
                          var connect = await System().checkConnections();
                          if (connect) {
                            setState(() {
                              isloading = true;
                            });
                            await notifier.initialOtherProfile(context, argument: widget.arguments).then((value) => isloading = false);
                          }
                        },
                      )
                    : CustomScrollView(
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
                            child: MeasuredSize(
                              onChange: (e) async {
                                heightProfileCard = e.height;
                                // await Future.delayed(Duration(milliseconds: 300), () {
                                //   isloading = true;
                                // });
                                // // await Future.delayed(Duration(milliseconds: 1000), () {
                                // isloading = false;
                                // // });
                                // print("=============================== height");
                                // print(heightProfileCard);
                              },
                              child: Container(
                                child: notifier.user.profile != null
                                    ? notifier.statusFollowing == StatusFollowing.following
                                        ? OtherProfileTop(
                                            // email: widget.arguments.senderEmail ?? '',
                                            email: userData?.profile?.email ?? '',
                                            profile: userData?.profile,
                                            otherStoryGroup: otherStoryGroup,
                                          )
                                        : OtherProfileTop(
                                            // email: widget.arguments.senderEmail ?? '',
                                            email: userData?.profile?.email ?? '',
                                            profile: userData?.profile,
                                            otherStoryGroup: otherStoryGroup,
                                          )
                                    : BothProfileTopShimmer(),
                              ),
                            ),
                          ),
                          SliverAppBar(
                            pinned: true,
                            flexibleSpace: OtherProfileBottom(email: widget.arguments.senderEmail),
                            automaticallyImplyLeading: false,
                            backgroundColor: Theme.of(context).colorScheme.background,
                          ),
                          if (notifier.user.profile != null && notifier.statusFollowing == StatusFollowing.following)
                            isloading
                                ? BothProfileContentShimmer()
                                : !notifier.isConnectContent
                                    ? SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: OfflineMode(
                                          function: () async {
                                            var connect = await System().checkConnections();
                                            if (connect) {
                                              setState(() {
                                                isloading = true;
                                              });
                                              await notifier.initialOtherProfile(context, argument: widget.arguments).then((value) => isloading = false);
                                            }
                                          },
                                        ),
                                      )
                                    : optionButton(notifier.isLoading, notifier.pageIndex, heightProfileCard)
                          // else if (notifier.peopleProfile?.userDetail?.data?.isPrivate ?? false)
                          //     SliverList(delegate: SliverChildListDelegate([PrivateAccount()]))
                          else
                            isloading
                                ? BothProfileContentShimmer()
                                : !notifier.isConnectContent
                                    ? SliverFillRemaining(
                                        hasScrollBody: false,
                                        child: OfflineMode(
                                          function: () async {
                                            var connect = await System().checkConnections();
                                            if (connect) {
                                              setState(() {
                                                isloading = true;
                                              });
                                              await notifier.initialOtherProfile(context, argument: widget.arguments).then((value) => isloading = false);
                                            }
                                          },
                                        ),
                                      )
                                    : optionButton(notifier.isLoading, notifier.pageIndex, heightProfileCard)
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
