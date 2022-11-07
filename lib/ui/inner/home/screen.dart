import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/inner/home/widget/filter.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
// v2 view
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/screen.dart';

import '../../../core/services/route_observer_service.dart';
import '../../constant/widget/after_first_layout_mixin.dart';
import 'content_v2/profile/self_profile/notifier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware, AfterFirstLayoutMixin {
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    print('didPop isOnHomeScreen false');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.didPop();
  }

  // @override
  // void didPush() {
  //   Future.delayed(Duration(seconds: 1), (){
  //     print('didPush isOnHomeScreen ${!SharedPreference().readStorage(SpKeys.isOnHomeScreen)}');
  //     SharedPreference().writeStorage(SpKeys.isOnHomeScreen, !SharedPreference().readStorage(SpKeys.isOnHomeScreen));
  //   });
  //   super.didPush();
  // }

  @override
  void didPopNext() {
    Future.delayed(Duration(milliseconds: 500), () {
      print('didPopNext isOnHomeScreen true');
      SharedPreference().writeStorage(SpKeys.isOnHomeScreen, true);
    });

    super.didPopNext();
  }

  @override
  void didPushNext() {
    print('didPushNext isOnHomeScreen false');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.didPushNext();
  }

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    // print('isOnHomeScreen false');
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.dispose();
  }

  @override
  void deactivate() {
    print('deactivate isOnHomeScreen false');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.deactivate();
  }

  @override
  void didPush() {
    print('didPush isOnHomeScreen true');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
  }

  @override
  void initState() {


    Future.delayed(Duration.zero, () {
      context.read<HomeNotifier>().setSessionID();
      final _language = context.read<TranslateNotifierV2>().translate;
      final notifierFollow = context.read<FollowRequestUnfollowNotifier>();
      if (notifierFollow.listFollow.isEmpty) {
        notifierFollow.listFollow = [
          {'name': "${_language.follow}", 'code': 'TOFOLLOW'},
          {'name': "${_language.following}", 'code': 'FOLLOWING'},
        ];
      }
    });

    context.read<PreUploadContentNotifier>().onGetInterest(context);

    if (mounted) {
      setState(() => {});
    }
    super.initState();
    print('ini iniststate home');

    // Future.delayed(const Duration(seconds: 10), () {
    //   if (mounted) {
    //     final notifier = Provider.of<CacheService>(context, listen: false);
    //     notifier.saveCache();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(SizeWidget.appBarHome),
          child: HomeAppBar(),
        ),
        body: RefreshIndicator(
          key: _globalKey,
          strokeWidth: 2.0,
          color: Colors.purple,
          onRefresh: () => notifier.onRefresh(context, notifier.visibilty),
          child: Stack(
            children: [
              // notifier.isLoadingVid
              // ? ListView(
              //     controller: _scrollController,
              //     physics: const AlwaysScrollableScrollPhysics(),
              //     children: const [
              //       ProcessUploadComponent(),
              //       HyppePreviewStories(),
              //       FilterLanding(),
              //       Padding(
              //         padding: EdgeInsets.only(top: 100.0),
              //         child: CustomLoading(),
              //       ),
              //     ],
              //   )
              // :
              ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  ProcessUploadComponent(),
                  HyppePreviewStories(),
                  FilterLanding(),
                  HyppePreviewVid(),
                  HyppePreviewDiary(),
                  HyppePreviewPic(),
                ],
              ),
              // CustomPopUpNotification()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }
}
