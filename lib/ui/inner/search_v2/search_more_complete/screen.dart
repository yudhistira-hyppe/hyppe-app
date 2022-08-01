import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/account_search_content.dart';
import 'package:hyppe/ui/inner/search_v2/search_more_complete/widget/all_search_content.dart';
import 'package:hyppe/ui/inner/search_v2/widget/search_content.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:provider/provider.dart';

class SearchMoreCompleteScreen extends StatefulWidget {
  const SearchMoreCompleteScreen({Key? key}) : super(key: key);

  @override
  _SearchMoreCompleteScreenState createState() => _SearchMoreCompleteScreenState();
}

class _SearchMoreCompleteScreenState extends State<SearchMoreCompleteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _tabController = TabController(length: 5, vsync: this);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () => notifier.onInitialSearch(context));
    super.initState();
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
      final List _list = [notifier.language.all, notifier.language.account, 'HyppeVid', 'HyppeDiary', 'HyppePic'];
      return Scaffold(
        key: _scaffoldKey,
        // endDrawerEnableOpenDragGesture: true,
        // endDrawer: FilterSearchMoreCompleteScreen(),
        body: SafeArea(
          child: Column(
            children: [
              const ProcessUploadComponent(topMargin: 0.0),
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
                                hintText: notifier.language.whatAreYouFindOut,
                                contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                                focusNode: notifier.focusNode,
                                controller: notifier.searchController,
                                onSubmitted: (v) => notifier.onSearchPost(context, value: v),
                                onPressedIcon: () => notifier.onSearchPost(context),
                                onTap: () => notifier.moveSearchMore(),
                                autoFocus: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        // physics: const BouncingScrollPhysics(),
                        // indicatorSize: TabBarIndicatorSize.tab,
                        // labelPadding: const EdgeInsets.symmetric(vertical: 8),
                        // labelColor: Theme.of(context).tabBarTheme.labelColor,
                        // unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
                        // labelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 16 * SizeConfig.scaleDiagonal),
                        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryVariant, width: 2.0)),
                        // unselectedLabelStyle: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w400, fontSize: 16 * SizeConfig.scaleDiagonal),

                        tabs: _list.map((e) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(8.0, 0, 8, 13),
                            child: Center(
                              child: Text(
                                e,
                                style: TextStyle(fontSize: 14),
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
                          : Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: TabBarView(
                                  // physics: const NeverScrollableScrollPhysics(),
                                  controller: _tabController,
                                  children: [
                                    AllSearchContent(content: notifier.searchContent, featureType: notifier.vidContentsQuery.featureType),
                                    AccountSearchContent(content: notifier.searchContent, featureType: notifier.vidContentsQuery.featureType),
                                    SearchContent(content: notifier.searchContent?.vid?.data, featureType: notifier.diaryContentsQuery.featureType),
                                    SearchContent(content: notifier.searchContent?.diary?.data, featureType: notifier.picContentsQuery.featureType),
                                    SearchContent(content: notifier.searchContent?.pict?.data, featureType: notifier.picContentsQuery.featureType),
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
