import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_see_all_title.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/see_all/widget/content_item.dart';
import 'package:hyppe/ui/inner/home/content_v2/diary/see_all/diary_see_all_notifier.dart';

class DiarySeeAllScreen extends StatefulWidget {
  const DiarySeeAllScreen({Key? key}) : super(key: key);

  @override
  State<DiarySeeAllScreen> createState() => _DiarySeeAllScreenState();
}

class _DiarySeeAllScreenState extends State<DiarySeeAllScreen> with SingleTickerProviderStateMixin {
  final notifier = DiarySeeAllNotifier();

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    notifier.initState(context);
    context.read<ReportNotifier>().inPosition = contentPosition.seeAllDiary;
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
    return ChangeNotifierProvider<DiarySeeAllNotifier>(
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
                  textToDisplay: _language.diariesForYou ?? '',
                  textStyle: theme.textTheme.bodyText1,
                ),
                eightPx,
                const CustomSeeAllTitle(title: 'HyppeDiary'),
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
            //     notifier.initialDiary(context, reload: true);
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
