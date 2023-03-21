import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_see_all_title.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/widget/content_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/see_all/vid_see_all_notifier.dart';

class VidSeeAllScreen extends StatefulWidget {
  const VidSeeAllScreen({Key? key}) : super(key: key);

  @override
  State<VidSeeAllScreen> createState() => _VidSeeAllScreenState();
}

class _VidSeeAllScreenState extends State<VidSeeAllScreen> with SingleTickerProviderStateMixin {
  final notifier = VidSeeAllNotifier();

  late TabController _tabController;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'VidSeeAllScreen');
    _tabController = TabController(length: 1, vsync: this);
    notifier.initState(context);
    context.read<ReportNotifier>().inPosition = contentPosition.seeAllVid;
    super.initState();
  }

  @override
  void dispose() {
    notifier.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _language = context.watch<TranslateNotifierV2>().translate;
    return ChangeNotifierProvider<VidSeeAllNotifier>(
      create: (context) => notifier,
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: _language.vidsForYou ?? '',
                  textStyle: theme.textTheme.bodyText1,
                ),
                eightPx,
                const CustomSeeAllTitle(title: 'HyppeVid'),
              ],
            ),
            // bottom: TabBar(
            //   controller: _tabController,
            //   tabs: [
            //     Tab(text: _language.trends),
            //     Tab(text: _language.news),
            //     Tab(text: _language.following),
            //     // FiltersButton(),
            //   ],
            //   onTap: (value) {
            //     // if (value == 3) {
            //     //   _tabController.index = _tabController.previousIndex;
            //     // } else {
            //     //   notifier.initialDiary(context, reload: true);
            //     // }
            //     notifier.initialVid(context, reload: true);
            //   },
            // ),
            automaticallyImplyLeading: true,
          ),
          backgroundColor: theme.colorScheme.background,
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              ContentItem(),
              // ContentItem(),
              // ContentItem(),
              // ContentItem(),
            ],
          ),
        ),
      ),
    );
  }
}
