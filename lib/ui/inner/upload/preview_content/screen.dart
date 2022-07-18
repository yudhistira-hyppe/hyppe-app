import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/upload/preview_content/content/preview_content.dart';
import 'package:hyppe/ui/inner/upload/preview_content/content/preview_id_verification.dart';
import 'package:hyppe/ui/inner/upload/preview_content/notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewContentScreen extends StatefulWidget {
  const PreviewContentScreen({Key? key}) : super(key: key);

  @override
  _PreviewContentScreenState createState() => _PreviewContentScreenState();
}

class _PreviewContentScreenState extends State<PreviewContentScreen> {
  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    final _notifier = Provider.of<PreviewContentNotifier>(context, listen: false);
    _notifier.initialMatrixColor();
    super.initState();
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
