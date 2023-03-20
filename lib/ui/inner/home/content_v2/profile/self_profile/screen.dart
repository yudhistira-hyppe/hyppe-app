import 'dart:async';

import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/arguments/other_profile_argument.dart';
import 'package:hyppe/core/bloc/ads_video/bloc.dart';
import 'package:hyppe/core/bloc/ads_video/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/advertising/ads_video_data.dart';
import 'package:hyppe/core/models/collection/advertising/view_ads_request.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_bottom.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/widget/self_profile_top.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/widget/both_profile_top_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/transaction/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class SelfProfileScreen extends StatefulWidget {
  final GeneralArgument? arguments;
  const SelfProfileScreen({super.key, this.arguments});

  @override
  _SelfProfileScreenState createState() => _SelfProfileScreenState();
}

class _SelfProfileScreenState extends State<SelfProfileScreen> with RouteAware, AfterFirstLayoutMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    print('asdasdad');
    final notifier = context.read<SelfProfileNotifier>();
    notifier.setPageIndex(0);
    _scrollController.addListener(() => notifier.onScrollListener(context, _scrollController));
    // ShowGeneralDialog.adsRewardPop(context);
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SelfProfileNotifier>();
    System().disposeBlock();
    notifier.initialSelfProfile(context);
  }

  @override
  void didPopNext() {
    System().disposeBlock();
    super.didPopNext();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future adsView(BuildContext context, {bool isClick = false}) async {
    bool lanjutan = false;
    try {
      final notifier = AdsDataBloc();
      final request = ViewAdsRequest(
        watchingTime: 11,
        adsId: '63bfebdfa121c14ab4a564cb',
        useradsId: '63d0ea69d4c2c926ce5cad12',
      );
      await notifier.viewAdsBloc(context, request, isClick: isClick);

      final fetch = notifier.adsDataFetch;
      // if (fetch.adsDataState == AdsDataState.getAdsVideoBlocSuccess) {
      // print("ini hasil ${fetch.data['rewards']}");
      // if (fetch.data['rewards'] == true) {
      print("ini hasil ${mounted}");

      var res = await ShowGeneralDialog.adsRewardPop(context);
      Timer(const Duration(milliseconds: 800), () {
        Routing().moveBack();
        Timer(const Duration(milliseconds: 800), () {
          Routing().moveBack();
        });
      });
      return lanjutan;
    } catch (e) {
      // 'Failed hit view ads $e'.logger();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<SelfProfileNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          if (widget.arguments?.isTrue == null) {
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
          body: RefreshIndicator(
            key: _globalKey,
            strokeWidth: 2.0,
            color: Colors.purple,
            onRefresh: () async {
              await notifier.getDataPerPgage(context, isReload: true);
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
                //   expandedHeight: (400 * SizeConfig.scaleDiagonal) + 46,
                //   backgroundColor: Theme.of(context).colorScheme.background,
                //   flexibleSpace: FlexibleSpaceBar(
                //       titlePadding: EdgeInsets.zero,
                //       background: notifier.user.profile != null
                //           ? SelfProfileTop()
                //           : BothProfileTopShimmer()),
                // ),
                SliverToBoxAdapter(
                  child: Container(child: notifier.user.profile != null ? const SelfProfileTop() : BothProfileTopShimmer()),
                ),

                SliverAppBar(
                  pinned: true,
                  flexibleSpace: const SelfProfileBottom(),
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.background,
                ),

                notifier.optionButton(),
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
        ),
      ),
    );
  }
}
