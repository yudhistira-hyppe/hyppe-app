import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more/widget/auto_complete_search.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:provider/provider.dart';

class SearchMoreScreen extends StatefulWidget {
  const SearchMoreScreen({Key? key}) : super(key: key);

  @override
  _SearchMoreScreenState createState() => _SearchMoreScreenState();
}

class _SearchMoreScreenState extends State<SearchMoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? lastInputValue;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
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
      return WillPopScope(
        onWillPop: () async {
          notifier.backFromSearchMore();

          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          // endDrawerEnableOpenDragGesture: true,
          // endDrawer: FilterSearchMoreScreen(),
          body: SafeArea(
            child: Column(
              children: [
                const ProcessUploadComponent(topMargin: 0.0),
                Flexible(
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconButtonWidget(
                              onPressed: () => notifier.backFromSearchMore(),
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
                                    onSubmitted: (v) => notifier.onSearchPost(context),
                                    onPressedIcon: () => notifier.onSearchPost(context),
                                    autoFocus: true,
                                    onChanged: (e) {
                                      if (e.length > 2) {
                                        if (lastInputValue != e) {
                                          lastInputValue = e;
                                          notifier.searchPeople(context, input: e);
                                        }
                                      }
                                    }),
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: AutoCompleteSearch()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
