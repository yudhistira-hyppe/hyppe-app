import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/search_v2/notifier.dart';
import 'package:hyppe/ui/inner/search_v2/search_more/widget/new_autocomplete_search.dart';
import 'package:provider/provider.dart';

class SearchMoreScreen extends StatefulWidget {
  const SearchMoreScreen({Key? key}) : super(key: key);

  @override
  _SearchMoreScreenState createState() => _SearchMoreScreenState();
}

class _SearchMoreScreenState extends State<SearchMoreScreen>
    with SingleTickerProviderStateMixin, AfterFirstLayoutMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? lastInputValue;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    final notifier = Provider.of<SearchNotifier>(context, listen: false);
    notifier.onInitialSearch(context);
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = context.read<SearchNotifier>();
    notifier.getHistories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<SearchNotifier>(builder: (context, notifier, child) {
      final values = notifier.riwayat;
      values?.sort((a, b) => DateTime.parse(b.datetime ?? '')
          .compareTo(DateTime.parse(a.datetime ?? '')));
      // if(values != null){
      //   for(final data in values){
      //     print('riwayat data: ${data.toJson(withID: true)}');
      //   }
      // }

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // const ProcessUploadComponent(topMargin: 0.0),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: CustomSearchBar(
                                  hintText: notifier.language.whatAreYouFindOut,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 16 * SizeConfig.scaleDiagonal),
                                  focusNode: notifier.focusNode,
                                  controller: notifier.searchController,
                                  onSubmitted: (v) {
                                    notifier.limit = 5;
                                    notifier.tabIndex = 0;
                                    // notifier.onSearchPost(context, isMove: true);
                                  },
                                  onPressedIcon: () {
                                    notifier.tabIndex = 0;
                                    notifier.limit = 5;
                                    // notifier.onSearchPost(context, isMove: true);
                                  },
                                  autoFocus: true,
                                  onChanged: (e) {
                                    final isHashtag = e.isHashtag();
                                    if (e.length > (isHashtag ? 3: 2)) {
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        if (lastInputValue != e) {
                                          lastInputValue = e;

                                          notifier.getDataSearch(context,
                                              typeSearch: isHashtag
                                                  ? SearchLoadData.hashtag
                                                  : SearchLoadData.user);
                                        }
                                      });
                                    }
                                  }),
                            ),
                          ),
                        ],
                      ),
                      notifier.searchController.text.length > 2
                          ? const Expanded(child: NewAutoCompleteSearch())
                          : Builder(builder: (context) {
                              if (values != null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [...[
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                                      child: CustomTextWidget(
                                        textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: context.getColorScheme().onBackground),
                                        textAlign: TextAlign.start,
                                          textToDisplay: notifier.language.searchHistory ?? 'Search History'),
                                    ),
                                  ],...List.generate(
                                      values.length > 10 ? 10 : values.length,
                                      (index) => InkWell(
                                        onTap: (){
                                          notifier.searchController.text = values[index].keyword ?? '';
                                          notifier.layout = SearchLayout.searchMore;
                                        },
                                        child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 18,
                                                  right: 20,
                                                  top: 16,
                                                  bottom: 16),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: CustomTextWidget(
                                                      textToDisplay:
                                                          values[index].keyword ??
                                                              '',
                                                      textAlign: TextAlign.start,
                                                        textStyle: context.getTextTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, color: context.getColorScheme().onBackground)
                                                    ),
                                                  ),
                                                  tenPx,
                                                  InkWell(
                                                    onTap: (){
                                                      notifier.deleteHistory(values[index]);
                                                    },
                                                    child: const CustomIconWidget(
                                                      iconData:
                                                          '${AssetPath.vectorPath}close.svg',
                                                      height: 25,
                                                      width: 25,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                      )).toList()],
                                );
                              }
                              return const SizedBox.shrink();
                            }),
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
