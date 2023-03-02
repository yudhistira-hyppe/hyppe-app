import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/models/collection/utils/interest/interest_data.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/detail_screen.dart';
import 'package:hyppe/ui/inner/search_v2/hashtag/screen.dart';
import 'package:hyppe/ui/inner/search_v2/interest/screen.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more/screen.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/screen.dart';
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
      (materialAppKey.currentContext ?? context).read<ReportNotifier>().inPosition = contentPosition.searchFirst;
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
    super.didPush();
  }

  final interests = [
    InterestData(
      id: '1',
      interestName: 'Hiburan',
      interestNameId: '1',
      icon: '${AssetPath.pngPath}hiburan.png',
      langID: 'id',
      cts: '',
    ),
    InterestData(
      id: '2',
      interestName: 'Gaming',
      interestNameId: '2',
      icon: '${AssetPath.pngPath}gaming.png',
      langID: 'id',
      cts: '',
    ),
    InterestData(
      id: '3',
      interestName: 'Film',
      interestNameId: '3',
      icon: '${AssetPath.pngPath}film.png',
      langID: 'id',
      cts: '',
    ),
    InterestData(
      id: '4',
      interestName: 'Fashion',
      interestNameId: '4',
      icon: '${AssetPath.pngPath}fashion.png',
      langID: 'id',
      cts: '',
    ),
    InterestData(
      id: '5',
      interestName: 'Akun Selebriti',
      interestNameId: '5',
      icon: '${AssetPath.pngPath}akun_selebriti.png',
      langID: 'id',
      cts: '',
    ),
    InterestData(
      id: '6',
      interestName: 'Travel',
      interestNameId: '6',
      icon: '${AssetPath.pngPath}travel.png',
      langID: 'id',
      cts: '',
    ),
  ];

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
        child: _searchLayout(notifier.layout, notifier),
      ),
    );
  }

  Widget _firstLayout(SearchNotifier notifier){
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
        child: HomeAppBar(),
      ),
      // endDrawerEnableOpenDragGesture: true,
      // endDrawer: FilterSearchScreen(),
      body: SingleChildScrollView(
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
                // onTap: () => notifier.moveSearchMore(),
                // onTap: () => _scaffoldKey.currentState.openEndDrawer(),
                onTap: (){
                  notifier.layout = SearchLayout.search;
                },
              ),
            ),
            const HashtagScreen(),
            InterestScreen(data: interests,),
          ],
        ),
      ),
    );
  }

  Widget _searchLayout(SearchLayout state, SearchNotifier notifier){
    switch(state){
      case SearchLayout.first:
        return _firstLayout(notifier);
      case SearchLayout.search:
        return const SearchMoreScreen();
      case SearchLayout.searchMore:
        return const SearchMoreCompleteScreenV2();
      case SearchLayout.mainHashtagDetail:
        if(notifier.selectedHashtag != null){
          return DetailHashtagScreen(isTitle: true, hashtag: notifier.selectedHashtag!);
        }else{
          return _firstLayout(notifier);
        }
      case SearchLayout.hashtagDetail:
        if(notifier.selectedHashtag != null){
          return DetailHashtagScreen(isTitle: false, hashtag: notifier.selectedHashtag!);
        }else{
          return _firstLayout(notifier);
        }

    }
  }
}
