import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/search_v2/interest/widget/tab_layout.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_path.dart';
import '../../../../core/models/collection/search/search_content.dart';
import '../../../../core/services/route_observer_service.dart';
import '../../../constant/widget/icon_button_widget.dart';
import '../notifier.dart';

class InterestDetailScreen extends StatefulWidget {
  Interest data;
  InterestDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<InterestDetailScreen> createState() => _InterestDetailScreenState();
}

class _InterestDetailScreenState extends State<InterestDetailScreen> with RouteAware, SingleTickerProviderStateMixin, AfterFirstLayoutMixin{
  late TabController _tabController;
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  // final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  int heightTab = 0;

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    final index = notifier.listInterest?.indexOf(widget.data) ?? 0;
    _tabController.index = index;
    _tabController.notifyListeners();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {

    final notifier = Routing.navigatorKey.currentContext!.read<SearchNotifier>();
    Future.delayed(Duration(milliseconds: 500), () {
      try{
        var jumpTo = heightTab + notifier.heightIndex - 10;
        print("jumpt ====== ${jumpTo}");
        print("jumpt ====== ${heightTab}");
        print("jumpt ====== ${notifier.heightIndex}");
        _scrollController.jumpTo(jumpTo.toDouble());
      }catch(e){
        print('jumpt error: $e');
      }

    });

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
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'InterestDetailScreen');
    _tabController = TabController(length: 6, vsync: this);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    _tabController.addListener(() {
      notifier.tabIndex = _tabController.index;
      setState(() {
        _selectedIndex = _tabController.index;
        // notifier.limit = 20;
        // notifier.onSearchPost(context);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchNotifier>(builder: (context, notifier, _){
      return Scaffold(
          appBar: AppBar(
            leading: CustomIconButtonWidget(
              onPressed: () => notifier.backFromSearchMore(),
              defaultColor: false,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: CustomTextWidget(
              textToDisplay: notifier.language.moreContents ?? 'More Contents',
              textStyle: context
                  .getTextTheme()
                  .bodyText1
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)),

                tabs: (notifier.listInterest ?? []).map((e) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(8.0, 20, 8, 13),
                    child: Center(
                      child: Text(
                          context.isIndo() ? (e.interestNameId ?? '') : (e.interestName ?? ''),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                }).toList().sublist(0, (notifier.listInterest ?? []).length > 6 ? 6 : (notifier.listInterest ?? []).length),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: TabBarView(
                    // physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: (notifier.listInterest ?? []).map((e) {

                      return InterestTabLayout(interest: e, scrollController: _scrollController,);

                    }).toList().sublist(0, (notifier.listInterest ?? []).length > 6 ? 6 : (notifier.listInterest ?? []).length),
                  ),
                ),
              )
            ],
          )
      );
    });
  }


}
