import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/monetization/historyordercoin/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_dropdown_widget.dart';
import 'package:hyppe/ui/inner/home/widget/loadmore.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'notifier.dart';
import 'widgets/history_coin.dart';
import 'widgets/shimmer_widget.dart';

class HistoryOrderCoinScreen extends StatefulWidget {
  const HistoryOrderCoinScreen({super.key});

  @override
  State<HistoryOrderCoinScreen> createState() => _HistoryOrderCoinScreenState();
}

class _HistoryOrderCoinScreenState extends State<HistoryOrderCoinScreen> {
  LocalizationModelV2? lang;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'history_order_coin');
    lang = context.read<TranslateNotifierV2>().translate;
    var notifier =
          Provider.of<HistoryOrderCoinNotifier>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      initializeDateFormatting('id', null);
      notifier.getTypeFilter(context);
      notifier.initHistory(context, mounted);
      notifier.page = 0;
    });
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (notifier.isLoadMore) {
          return;
        }

        if (mounted) {
          notifier.isLoadMore = true;
        }

        if (!notifier.isLastPage && notifier.isLoadMore) {
          await notifier.loadMore(context, mounted);
        }

        if (mounted) {
          notifier.isLoadMore = false;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: () => Routing().moveBack(),
            icon: const Icon(Icons.arrow_back_ios)),
        title: CustomTextWidget(
          textStyle: theme.textTheme.titleMedium,
          textToDisplay: lang?.yourorder ?? 'Pesanan Kamu',
        ),
        actions: [
          IconButton(
              onPressed: () {
                Fluttertoast.showToast(msg: 'Feature not yet available');
              },
              icon: const Icon(Icons.info_outline_rounded))
        ],
      ),
      body: Consumer<HistoryOrderCoinNotifier>(builder: (context, notifier, _) {
        if ((notifier.bloc.dataFetch.dataState == HistoryOrderCoinState.init ||
                notifier.bloc.dataFetch.dataState ==
                    HistoryOrderCoinState.loading) &&
            !notifier.isLoadMore) {
          return const ContentLoader();
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              notifier.isLoadMore = false;
              notifier.isLastPage = false;

              await notifier.initHistory(context, mounted);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: notifier.isLoadMore ? notifier.result.length+2 : notifier.result.length+1,
                itemBuilder: (context, index) {
                  if (notifier.result.length + 1 == index){
                    return const CustomLoading();
                  }

                  if (index == 0) {
                    return filtersData(notifier);
                  }

                  if (notifier.result.isEmpty) {
                    return Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 18.0),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CustomIconWidget(
                              iconData:
                                  '${AssetPath.vectorPath}icon_no_result.svg',
                              width: 160,
                              height: 160,
                              defaultColor: false,
                            ),
                            tenPx,
                            CustomTextWidget(
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              textToDisplay: lang?.localeDatetime == 'id'
                                  ? 'Masih sepi, nih'
                                  : 'There\'s no one here',
                              textStyle: context
                                  .getTextTheme()
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context
                                          .getColorScheme()
                                          .onBackground),
                            ),
                            eightPx,
                            CustomTextWidget(
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              textToDisplay: lang?.localeDatetime == 'id'
                                  ? 'Yuk, mulai miliki penghasilan dari membuat konten dan dukung creator favoritmu!'
                                  : 'Let\'s start earning from creating content and supporting your favorite creators!',
                              textStyle: context.getTextTheme().bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return HistoryCoinWidget(
                    data: notifier.result[index - 1],
                    lang: lang,
                  );
                },
              ),
            ),
          );
        }
      }),
    );
  }

  Widget filtersData(HistoryOrderCoinNotifier notifier) {
    return Container(
      height: kToolbarHeight - 8,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          Visibility(
            visible: notifier.selectedDateValue != 1,
            child: GestureDetector(
              onTap: () => notifier.resetSelected(context, mounted),
              child: Container(
                margin: const EdgeInsets.only(right: 12.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                    border: Border.all(color: kHyppeBurem, width: .5),
                    borderRadius: BorderRadius.circular(32.0)),
                child: const Icon(Icons.close),
              ),
            ),
          ),
          SectionDropdownWidget(
            title: notifier.selectedDateLabel,
            onTap: () => notifier.showButtomSheetDate(context),
            isActive: notifier.groupsDate
                        .firstWhere((e) => e.selected == true)
                        .index ==
                    1
                ? false
                : true,
          ),
        ],
      ),
    );
  }
}
