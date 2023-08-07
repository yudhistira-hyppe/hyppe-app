import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/arguments/hashtag_argument.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/detail_screen.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/screen.dart';
import 'package:hyppe/ui/inner/search_v2/interest/screen.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more/screen.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/screen.dart';
import 'package:hyppe/ui/inner/search_v2/widget/event_banner.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import '../../../core/constants/asset_path.dart';
import '../../../core/constants/shared_preference_keys.dart';
import '../../../core/constants/themes/hyppe_colors.dart';
import '../../../core/services/shared_preference.dart';
import '../../../ux/path.dart';
import '../../../ux/routing.dart';
import '../../constant/widget/custom_icon_widget.dart';
import '../../constant/widget/custom_spacer.dart';
import '../home/content_v2/profile/self_profile/widget/offline_mode.dart';
import 'interest/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with RouteAware, SingleTickerProviderStateMixin, AfterFirstLayoutMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CarouselController _controllerSlider = CarouselController();

  late TabController _tabController;
  int _currentIndex = 0;
  int _currentIndexSlider = 0;

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    final fcmToken = SharedPreference().readStorage(SpKeys.fcmToken);
    print('my Fcm Token: $fcmToken');
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SearchScreen');
    _tabController = TabController(length: 3, vsync: this);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    notifier.startLayout();
    _tabController.addListener(
      () {
        setState(() {
          print('tab controller');
          _currentIndex = _tabController.index;
          if (_currentIndex == 1) {
            notifier.onInitialSearchNew(context, FeatureType.diary);
          }
          if (_currentIndex == 2) {
            notifier.onInitialSearchNew(context, FeatureType.pic);
          }
          print(_currentIndex);
        });
      },
    );

    if (notifier.searchContentFirstPage?.video == null) {
      Future.delayed(Duration.zero, () => notifier.onInitialSearchNew(context, FeatureType.vid));
    }
    context.read<ReportNotifier>().setPosition(contentPosition.searchFirst);
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    notifier.onSearchLandingPage(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPop() {
    'didPop searchFirst false'.logger();
    super.didPop();
  }

  @override
  void didPopNext() {
    Future.delayed(const Duration(milliseconds: 500), () {
      (Routing.navigatorKey.currentContext ?? context).read<ReportNotifier>().inPosition = contentPosition.searchFirst;
      final notifier = Routing.navigatorKey.currentContext!.read<SearchNotifier>();
      _controllerSlider.jumpToPage(_currentIndexSlider);
      if (notifier.layout == SearchLayout.searchMore) {
        // notifier.getDataSearch(context);
      }
    });
    // debugPrint(_currentIndexSlider.toString());
    //

    super.didPopNext();
  }

  @override
  void didPushNext() {
    'didPushNext searchFirst false'.logger();

    super.didPushNext();
  }

  @override
  void deactivate() {
    'deactivate searchFirst false'.logger();

    super.deactivate();
  }

  @override
  void didPush() {
    'didPush searchFirst false'.logger();
    super.didPush();
  }

  void changeIndexSlide(int val) {
    _currentIndexSlider = val;
    print(_currentIndexSlider); //newValue
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.getPost));
    return Consumer<SearchNotifier>(
      builder: (context, notifier, child) => WillPopScope(
        onWillPop: () async {
          if (notifier.layout != SearchLayout.first) {
            notifier.backFromSearchMore();
            // if(notifier.isFromComplete){
            //   notifier.layout = SearchLayout.searchMore;
            //   notifier.isFromComplete = false;
            // }else{
            //   notifier.layout = SearchLayout.first;
            //   notifier.isFromComplete = false;
            // }
            // notifier.layout = SearchLayout.first;
          } else {
            'pageIndex now: 0'.logger();
            context.read<MainNotifier>().pageIndex = 0;
          }
          return false;
        },
        child: Stack(
          children: [
            Positioned.fill(child: _searchLayout(notifier.layout, notifier)),
            if (notifier.loadPlaylist)
              Positioned.fill(
                  child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                alignment: Alignment.center,
                child: CustomLoading(),
              ))
          ],
        ),
      ),
    );
  }

  Widget _firstLayout(SearchNotifier notifier) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
        child: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: [
            // Doku(),
            // Profile(),
            // // AliPlayer(),
            // sixteenPx,
            Consumer<MainNotifier>(builder: (context, notifier, _) {
              final isReceived = notifier.receivedMsg;
              return GestureDetector(
                onTap: () {
                  Routing().move(Routes.message);
                  notifier.receivedMsg = false;
                },
                child: isReceived
                    ? CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}message_with_dot.svg')
                    : CustomIconWidget(defaultColor: false, color: kHyppeTextLightPrimary, iconData: '${AssetPath.vectorPath}message.svg'),
              );
            }),
            sixteenPx
          ],
          title: const CustomIconWidget(
            iconData: "${AssetPath.vectorPath}hyppe.svg",
            color: kHyppeTextLightPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        strokeWidth: 2.0,
        color: context.getColorScheme().primary,
        onRefresh: () => notifier.onSearchLandingPage(context),
        child: notifier.connectionError
            ? OfflineMode(
                function: () {
                  notifier.checkConnection();
                  notifier.onSearchLandingPage(context);
                },
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomSearchBar(
                        hintText: notifier.language.whatAreYouFindOut,
                        contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                        focusNode: notifier.focusNode1,
                        controller: notifier.searchController1,
                        onTap: () {
                          if (notifier.layout == SearchLayout.searchMore) {
                            notifier.isFromComplete = true;
                          }
                          notifier.layout = SearchLayout.search;
                        },
                      ),
                    ),
                    // EventBannerWidget(controller: _controllerSlider, callback: changeIndexSlide),
                    const HashtagScreen(),
                    InterestScreen(
                      onClick: (value) {
                        notifier.selectedInterest = value;
                        if (notifier.layout == SearchLayout.searchMore) {
                          notifier.isFromComplete = true;
                        }
                        notifier.layout = SearchLayout.interestDetail;
                      },
                    ),
                    sixtyFourPx,
                    sixtyFourPx
                  ],
                ),
              ),
      ),
    );
  }

  Widget _searchLayout(SearchLayout state, SearchNotifier notifier) {
    switch (state) {
      case SearchLayout.first:
        return _firstLayout(notifier);
      case SearchLayout.search:
        return const SearchMoreScreen();
      case SearchLayout.searchMore:
        return const SearchMoreCompleteScreenV2();
      case SearchLayout.mainHashtagDetail:
        if (notifier.selectedHashtag != null) {
          return DetailHashtagScreen(
            argument: HashtagArgument(isTitle: true, hashtag: notifier.selectedHashtag!),
          );
        } else {
          return _firstLayout(notifier);
        }
      case SearchLayout.hashtagDetail:
        if (notifier.selectedHashtag != null) {
          return DetailHashtagScreen(argument: HashtagArgument(isTitle: false, hashtag: notifier.selectedHashtag!));
        } else {
          return _firstLayout(notifier);
        }
      case SearchLayout.interestDetail:
        if (notifier.selectedInterest != null) {
          return InterestDetailScreen(data: notifier.selectedInterest!);
        } else {
          return _firstLayout(notifier);
        }
    }
  }
}
