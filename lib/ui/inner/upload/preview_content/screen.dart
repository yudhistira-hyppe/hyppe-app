import 'package:audioplayers/audioplayers.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/audio_service.dart';
import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/ui/inner/upload/preview_content/content/preview_content.dart';
import 'package:hyppe/ui/inner/upload/preview_content/content/preview_id_verification.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app.dart';

class PreviewContentScreen extends StatefulWidget {
  const PreviewContentScreen({Key? key}) : super(key: key);

  @override
  _PreviewContentScreenState createState() => _PreviewContentScreenState();
}

class _PreviewContentScreenState extends State<PreviewContentScreen> with WidgetsBindingObserver, TickerProviderStateMixin, RouteAware {
  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    MyAudioService.instance.stop();
    final _notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
    _notifier.initialMatrixColor();
    _notifier.scrollController = ScrollController();
    _notifier.scrollExpController = ScrollController();
    _notifier.audioPlayer = AudioPlayer();
    _notifier.isActivePagePreview = true;

    super.initState();
  }

  @override
  void dispose() {
    print('dispose PreviewContentScreen');
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.audioPlayer.stop();
    notifier.audioPlayer.dispose();
    notifier.isActivePagePreview = false;
    try {
      notifier.scrollController.dispose();
    } catch (e) {
      e.logger();
    }
    try {
      notifier.scrollExpController.dispose();
    } catch (e) {
      e.logger();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPushNext() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.isActivePagePreview = false;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    final notifier = materialAppKey.currentContext!.read<PreviewContentNotifier>();
    notifier.isActivePagePreview = true;
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<PreviewContentNotifier>(
      builder: (_, notifier, __) => notifier.featureType != null
          ? WillPopScope(
              onWillPop: () async => notifier.onWillPop(context),
              child: Scaffold(
                key: _scaffoldState,
                resizeToAvoidBottomInset: false,
                body: PreviewContent(
                  scaffoldState: _scaffoldState,
                  globalKey: _globalKey,
                  pageController: _pageController,
                ),
              ),
            )
          : WillPopScope(
              onWillPop: () async => notifier.onWillPop(context),
              child: Scaffold(
                body: PreviewIDVerification(
                  pageController: _pageController,
                  picture: notifier.fileContent?[0],
                ),
              ),
            ),
    );

    // return Consumer<PreviewContentNotifier>(
    //   builder: (_, notifier, __) => WillPopScope(
    //     onWillPop: () async => notifier.onWillPop(context),
    //     child: Scaffold(
    //       key: _scaffoldState,
    //       resizeToAvoidBottomInset: false,
    //       body: PreviewContent(
    //         globalKey: _globalKey,
    //         scaffoldState: _scaffoldState,
    //         pageController: _pageController,
    //       ),
    //     ),
    //   ),
    // );
  }
}
