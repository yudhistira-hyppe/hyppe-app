import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/pic/scroll/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/offline_mode.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_top.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_content_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_top_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/scroll/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:measured_size/measured_size.dart';

import '../../../../../../app.dart';
import '../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../constant/widget/custom_elevated_button.dart';
import '../../../notifier_v2.dart';

class SelfProfileScreen extends StatefulWidget {
  final GeneralArgument? arguments;
  const SelfProfileScreen({super.key, this.arguments});

  @override
  State<SelfProfileScreen> createState() => SelfProfileScreenState();
}

class SelfProfileScreenState extends State<SelfProfileScreen> with RouteAware, AfterFirstLayoutMixin {
  ScrollController _scrollController = ScrollController();
  final GlobalKey<NestedScrollViewState> _globalKey = GlobalKey<NestedScrollViewState>();
  double heightProfileCard = 0;
  bool isloading = false;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SelfProfileScreen');
    final notifier = context.read<SelfProfileNotifier>();
    notifier.setPageIndex(0);
    _scrollController.addListener(() => notifier.onScrollListener(context, scrollController: _scrollController));

    // ShowGeneralDialog.adsRewardPop(context);

    // _globalKey.currentState?.innerController.addListener(() {
    //   setState(() {});
    // });
    cekImei();

    super.initState();
  }

  void cekImei() async {
    var a = await System().getDeviceIdentifier();
    print("=====imeeiii======== $a");
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SelfProfileNotifier>();
    System().disposeBlock();
    notifier.initialSelfProfile(context);
    page = -1;
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    System().disposeBlock();
    try {
      if (mounted) {
        final sp = context.read<ScrollPicNotifier>();
        final sd = context.read<ScrollDiaryNotifier>();
        final sv = context.read<ScrollVidNotifier>();
        final spn = context.read<SelfProfileNotifier>();
        if (spn.user.pics != null) {
          sp.pics = spn.user.pics;
        }
        if (spn.user.diaries != null) {
          sd.diaryData = spn.user.diaries;
        }
        if (spn.user.vids != null) {
          sv.vidData = spn.user.vids;
        }
      }
    } catch (e) {
      print(e);
    }

    // Future.delayed(const Duration(milliseconds: 200), () {
    //   print("height dari bloc ${notifier.heightIndex}");
    //   if (notifier.heightIndex != 0) {
    //     if (notifier.pageIndex == 0 && notifier.picCount < 9) {
    //       return false;
    //     }
    //     if (notifier.pageIndex == 1 && notifier.diaryCount < 9) {
    //       return false;
    //     }
    //     if (notifier.pageIndex == 2 && notifier.vidCount < 9) {
    //       return false;
    //     }
    //     var jumpTo = heightProfileCard + notifier.heightIndex;
    //     _scrollController.jumpTo(jumpTo.toDouble());
    //     notifier.heightIndex = 0;
    //   }
    // });

    super.didPopNext();
  }

  @override
  void didPop() {
    print("==========pop===========");
    super.didPop();
  }

  @override
  void didPushNext() {
    print("========= didPushNext prfile =====");
    super.didPushNext();
  }

  @override
  void dispose() {
    print("========= dispose prfile =====");
    _scrollController.dispose();
    super.dispose();
  }

  void scrollAuto() {
    print("=-=-=-=- jump");
    try {
      _scrollController = ScrollController(initialScrollOffset: 10000);

      _scrollController.jumpTo(10000);
    } catch (e) {
      print(e);
    }

    // final notifier = context.read<SelfProfileNotifier>();
    // var jumpTo = heightProfileCard + notifier.heightIndex;
    // _scrollController.jumpTo(jumpTo.toDouble());
    // _scrollController.jumpTo(10000);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          if (widget.arguments?.isTrue == null) {
            'pageIndex now: 0'.logger();
            context.read<MainNotifier>().pageIndex = 0;
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: true,
            title: CustomTextWidget(
              textToDisplay: notifier.displayUserName(),
              textAlign: TextAlign.start,
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
            actions: [
              IconButton(
                // onPressed: () => notifier.routing.move(profileSettings),
                onPressed: () async {
                  notifier.routing.move(Routes.appSettings);
                  await context.read<TransactionNotifier>().getAccountBalance(context);
                  context.read<TransactionNotifier>().isLoading = false;
                },
                icon: const CustomIconWidget(
                  iconData: "${AssetPath.vectorPath}setting.svg",
                ),
              ),
            ],
            leading: IconButton(
              icon: const CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
              splashRadius: 1,
              onPressed: () {
                if (widget.arguments?.isTrue == null) {
                  context.read<MainNotifier>().pageIndex = 0;
                } else {
                  Routing().moveBack();
                }
              },
            ),
            // flexibleSpace: SafeArea(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.only(left: 16.0),
            //         child: CustomTextWidget(
            //           textToDisplay: notifier.displayUserName(),
            //           textAlign: TextAlign.start,
            //           textStyle: Theme.of(context).textTheme.subtitle1,
            //         ),
            //       ),
            //       IconButton(
            //         // onPressed: () => notifier.routing.move(profileSettings),
            //         onPressed: () async {
            //           notifier.routing.move(Routes.appSettings);
            //           await context.read<TransactionNotifier>().getAccountBalance(context);
            //           context.read<TransactionNotifier>().isLoading = false;
            //         },
            //         icon: const CustomIconWidget(
            //           iconData: "${AssetPath.vectorPath}setting.svg",
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),
          body: System().showWidgetForGuest(
              RefreshIndicator(
                key: _globalKey,
                strokeWidth: 2.0,
                color: Colors.purple,
                onRefresh: () async {
                  await notifier.getDataPerPgage(context, isReload: true);
                  context.read<HomeNotifier>().initNewHome(context, mounted);
                },
                child: isloading
                    ? CustomScrollView(
                        slivers: [SliverToBoxAdapter(child: BothProfileTopShimmer()), BothProfileContentShimmer()],
                      )
                    : !notifier.isConnect
                        ? OfflineMode(
                            function: () async {
                              var connect = await System().checkConnections();
                              if (connect) {
                                setState(() {
                                  isloading = true;
                                });
                                await notifier.initialSelfProfile(context).then((value) => isloading = false);
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
                              //   expandedHeight: (400 * SizeConfig.scaleDiagonal) + 46,
                              //   backgroundColor: Theme.of(context).colorScheme.background,
                              //   flexibleSpace: FlexibleSpaceBar(
                              //       titlePadding: EdgeInsets.zero,
                              //       background: notifier.user.profile != null
                              //           ? SelfProfileTop()
                              //           : BothProfileTopShimmer()),
                              // ),
                              SliverToBoxAdapter(
                                child: MeasuredSize(
                                    onChange: (e) async {
                                      if (mounted) {
                                        heightProfileCard = e.height;
                                        await Future.delayed(Duration(milliseconds: 300), () {
                                          isloading = true;
                                        });
                                        // await Future.delayed(Duration(milliseconds: 1000), () {
                                        isloading = false;
                                        // });
                                        print("=============================== height");
                                        print(heightProfileCard);
                                      }
                                    },
                                    child: Container(child: notifier.user.profile != null ? const SelfProfileTop() : BothProfileTopShimmer())),
                              ),

                              SliverAppBar(
                                pinned: true,
                                flexibleSpace: const SelfProfileBottom(),
                                automaticallyImplyLeading: false,
                                backgroundColor: Theme.of(context).colorScheme.background,
                              ),
                              notifier.optionButton(_scrollController, heightProfileCard),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return notifier.scollLoading ? const CustomLoading(size: 4) : Container();
                                  },
                                  childCount: 1,
                                ),
                              )
                            ],
                          ),
              ),
              SafeArea(
                child: Container(
                  width: double.infinity,
                  height: context.getHeight(),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 51),
                        child: const CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}avatar.svg'),
                      ),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 54),
                          child: const CustomTextWidget(
                            maxLines: 2,
                            textToDisplay: 'Masuk untuk nikmati fitur seru Hyppe secara lengkap',
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          )),
                      twentyFourPx,
                      CustomElevatedButton(
                        width: 259,
                        height: 36 * SizeConfig.scaleDiagonal,
                        buttonStyle: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                        ),
                        function: () {
                          ShowBottomSheet().onLoginApp(context);
                        },
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.login ?? 'Login',
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: kHyppeLightButtonText,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
