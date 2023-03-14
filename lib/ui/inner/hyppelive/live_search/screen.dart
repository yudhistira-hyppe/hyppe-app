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
import 'package:hyppe/ui/inner/live_search/notifier.dart';
//import 'package:hyppe/ui/inner/live_search/widget/option_bar.dart';
import 'package:hyppe/ui/inner/live_search/widget/live_search.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/extension/log_extension.dart';

class LiveSearchScreen extends StatefulWidget {
  @override
  _LiveSearchScreenState createState() => _LiveSearchScreenState();
}

class _LiveSearchScreenState extends State<LiveSearchScreen> with RouteAware, SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    final notifier = Provider.of<LiveSearchNotifier>(context, listen: false);
    if (notifier.searchContentFirstPage?.video == null) {
      Future.delayed(Duration.zero, () => notifier.onInitialSearchNew(context));
    }
    context.read<ReportNotifier>().setPosition(contentPosition.searchFirst);
    super.initState();
  }

  @override
  void dispose() {
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
    return Consumer<LiveSearchNotifier>(
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
          // endDrawer: FilterLiveSearchScreen(),
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
                          : LiveSearch(index: 0),
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
