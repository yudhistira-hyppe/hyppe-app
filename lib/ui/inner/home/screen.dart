import 'package:hyppe/core/constants/hyppe_version.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/inner/home/widget/filter.dart';
import 'package:hyppe/ui/inner/home/widget/home_app_bar.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/core/services/cache_service.dart';
// v2 view
import 'package:hyppe/ui/inner/home/content_v2/pic/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/preview/screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/stories/preview/screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Provider.of<HomeNotifier>(context, listen: false).setSessionID();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        final notifier = Provider.of<CacheService>(context, listen: false);
        notifier.saveCache();
      }
    });
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
          onRefresh: () => notifier.onRefresh(context),
          child: Stack(
            children: [
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
}
