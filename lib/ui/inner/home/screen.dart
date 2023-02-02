import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/follow/notifier.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
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
import 'package:screen_protector/screen_protector.dart';
import '../../../core/services/route_observer_service.dart';
import '../../constant/widget/after_first_layout_mixin.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:screenshot_callback/screenshot_callback.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware, AfterFirstLayoutMixin {
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  ScreenshotCallback screenshotCallback = ScreenshotCallback();

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    isHomeScreen = false;
    'didPop isOnHomeScreen $isHomeScreen'.logger();
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.didPop();
  }

  @override
  void didPopNext() {
    Future.delayed(const Duration(milliseconds: 500), () {
      isHomeScreen = true;
      'didPopNext isOnHomeScreen $isHomeScreen'.logger();
      // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, true);
      context.read<ReportNotifier>().inPosition = contentPosition.home;
    });

    System().disposeBlock(context);

    super.didPopNext();
  }

  @override
  void didPushNext() {
    isHomeScreen = false;
    'didPushNext isOnHomeScreen $isHomeScreen'.logger();
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
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
    isHomeScreen = false;
    'deactivate isOnHomeScreen $isHomeScreen'.logger();
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.deactivate();
  }

  @override
  void didPush() {
    // isHomeScreen = false;
    'didPush isOnHomeScreen $isHomeScreen'.logger();
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
  }

  @override
  void initState() {
    isHomeScreen = true;
    'isOnHomeScreen $isHomeScreen'.logger();
    Future.delayed(Duration.zero, () {
      final notifier = context.read<HomeNotifier>();
      notifier.setSessionID();
      final _language = context.read<TranslateNotifierV2>().translate;
      final notifierFollow = context.read<FollowRequestUnfollowNotifier>();

      notifier.initHome(context);
      if (notifierFollow.listFollow.isEmpty) {
        notifierFollow.listFollow = [
          {'name': "${_language.follow}", 'code': 'TOFOLLOW'},
          {'name': "${_language.following}", 'code': 'FOLLOWING'},
        ];
      }
      context.read<ReportNotifier>().inPosition = contentPosition.home;
      init();
    });

    context.read<PreUploadContentNotifier>().onGetInterest(context);

    if (mounted) {
      setState(() => {});
    }
    super.initState();
    'ini iniststate home'.logger();

    // Future.delayed(const Duration(seconds: 10), () {
    //   if (mounted) {
    //     final notifier = Provider.of<CacheService>(context, listen: false);
    //     notifier.saveCache();
    //   }
    // });
  }

  void init() async {
    await initScreenshotCallback();
  }

  //It must be created after permission is granted.
  Future<void> initScreenshotCallback() async {
    screenshotCallback = ScreenshotCallback();

    screenshotCallback.addListener(() {
      print('asd');
    });

    screenshotCallback.addListener(() {
      print("We can add multiple listeners ");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          MoveToBackground.moveTaskToBack();
          return false;
        },
        child: Scaffold(
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
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }
}
