import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/account_search_content.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/all_search_content.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/search_contents_tab.dart';
import 'package:provider/provider.dart';

import '../hashtag/tab_screen.dart';

class SearchMoreCompleteScreenV2 extends StatefulWidget {
  const SearchMoreCompleteScreenV2({Key? key}) : super(key: key);

  @override
  _SearchMoreCompleteScreenV2 createState() => _SearchMoreCompleteScreenV2();
}

class _SearchMoreCompleteScreenV2 extends State<SearchMoreCompleteScreenV2> with SingleTickerProviderStateMixin, AfterFirstLayoutMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void deactivate() {
    final notifier = context.read<SearchNotifier>();
    notifier.setEmptyLastKey();
    super.deactivate();
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SearchMoreCompleteScreenV2');
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    notifier.initSearchAll();
    _tabController = TabController(length: 4, vsync: this);
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
  void afterFirstLayout(BuildContext context) {
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    notifier.getDataSearch(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final error = context.select((ErrorService value) => value.getError(ErrorType.getPost));
    return Consumer<SearchNotifier>(builder: (context, notifier, child) {
      final List _list = [notifier.language.recommended, notifier.language.account, notifier.language.contents, notifier.language.hashtags];
      return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              // const ProcessUploadComponent(topMargin: 0.0),
              Flexible(
                child: DefaultTabController(
                  length: _list.length,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CustomIconButtonWidget(
                            onPressed: () {
                              notifier.backPage();
                            },
                            defaultColor: false,
                            iconData: "${AssetPath.vectorPath}back-arrow.svg",
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: CustomSearchBar(
                                readOnly: false,
                                hintText: notifier.language.whatAreYouFindOut,
                                contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                                focusNode: notifier.focusNode,
                                controller: notifier.searchController,
                                onSubmitted: (v) {
                                  final isHashTag = v.isHashtag();
                                  final lenght = v.length;
                                  final maxLenght = isHashTag ? 4 : 3;
                                  notifier.limit = 5;
                                  notifier.tabIndex = 0;
                                  if (lenght >= maxLenght) {
                                    notifier.getDataSearch(context);
                                  }
                                },
                                onPressedIcon: () {
                                  final isHashTag = notifier.searchController.text.isHashtag();
                                  final lenght = notifier.searchController.text.length;
                                  final maxLenght = isHashTag ? 4 : 3;
                                  notifier.limit = 5;
                                  notifier.tabIndex = 0;
                                  if (lenght >= maxLenght) {
                                    notifier.getDataSearch(context);
                                  }
                                },
                                // onTap: () => notifier.moveSearchMore(),
                                autoFocus: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0)),
                        tabs: _list.map((e) {
                          return Container(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 13),
                            child: Center(
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          );
                        }).toList(),
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
                          : Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: TabBarView(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  controller: _tabController,
                                  children: [
                                    AllSearchContent(tabController: _tabController, keyword: notifier.searchController.text,),
                                    AccountSearchContent(users: notifier.searchUsers),
                                    SearchContentsTab(keyword: notifier.searchController.text),
                                    const HashtagTabScreen(),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
