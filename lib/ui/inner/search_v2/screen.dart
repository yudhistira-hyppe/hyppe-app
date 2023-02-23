import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/widget/option_bar.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_content.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with RouteAware, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPop() {
    'didPop searfc false'.logger();
    super.didPop();
  }

  @override
  void didPopNext() {
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<ReportNotifier>().inPosition = contentPosition.searchFirst;
    });

    super.didPopNext();
  }

  @override
  void didPushNext() {
    'didPushNext searchFirst false'.logger();

    super.didPushNext();
  }

  @override
  void deactivate() {
    'deactivate searfc false'.logger();

    super.deactivate();
  }

  @override
  void didPush() {
    'didPush searfc false'.logger();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.getPost));
    return Consumer<SearchNotifier>(
      builder: (context, notifier, child) => WillPopScope(
        onWillPop: () async {
          context.read<MainNotifier>().pageIndex = 0;
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
            child: HomeAppBar(),
          ),
          // endDrawerEnableOpenDragGesture: true,
          // endDrawer: FilterSearchScreen(),
          body: Column(
            children: [
              // const ProcessUploadComponent(topMargin: 0.0),
              Flexible(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomSearchBar(
                          hintText: notifier.language.whatAreYouFindOut,
                          contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                          focusNode: notifier.focusNode1,
                          controller: notifier.searchController1,
                          // onSubmitted: (v) => notifier.onSearchPost(context, value: v),
                          // onPressedIcon: () => notifier.onSearchPost(context),
                          onTap: () => notifier.moveSearchMore(),
                          // onTap: () => _scaffoldKey.currentState.openEndDrawer(),
                        ),
                      ),
                      // const HashtagScreen(),
                      TabBar(
                        controller: _tabController,
                        // physics: const BouncingScrollPhysics(),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: const EdgeInsets.symmetric(vertical: 8),
                        labelColor: Theme.of(context).tabBarTheme.labelColor,
                        unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                        labelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 16 * SizeConfig.scaleDiagonal),
                        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)),
                        unselectedLabelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 16 * SizeConfig.scaleDiagonal),
                        tabs: const [
                          OptionBar(title: "Vid", icon: "vid", pageIndex: 0),
                          OptionBar(title: "Diary", icon: "diary", pageIndex: 1),
                          OptionBar(title: "Pic", icon: "pic", pageIndex: 2),
                          // CustomElevatedButton(
                          //     child: CustomTextWidget(
                          //       textToDisplay: context.select((SearchNotifier value) => value.language.filter),
                          //       textStyle: Theme.of(context).textTheme.button,
                          //     ),
                          //     width: 50,
                          //     height: 20 * SizeConfig.scaleDiagonal,
                          //     function: () {},
                          // ),
                        ],
                        onTap: (index) => notifier.pageIndex = index,
                      ),
                      context.read<ErrorService>().isInitialError(error, notifier.allContents)
                          ? Center(
                              child: SizedBox(
                                height: 198,
                                child: CustomErrorWidget(
                                  errorType: ErrorType.getPost,
                                  function: () => notifier.onInitialSearch(context),
                                ),
                              ),
                            )
                          : Flexible(
                              child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                controller: _tabController,
                                children: [
                                  SearchContent(featureType: FeatureType.vid, index: 0),
                                  SearchContent(featureType: FeatureType.diary, index: 1),
                                  SearchContent(featureType: FeatureType.pic, index: 2),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
