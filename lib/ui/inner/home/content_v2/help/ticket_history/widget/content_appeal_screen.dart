import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/widget/item_content_appeal.dart';
import 'package:provider/provider.dart';

import '../../../../../../constant/widget/after_first_layout_mixin.dart';
import '../../../../../../constant/widget/custom_loading.dart';
import '../../../../../../constant/widget/custom_shimmer.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';
import '../../../../../../constant/widget/no_result_found.dart';

class ContentAppealScreen extends StatefulWidget {
  const ContentAppealScreen({Key? key}) : super(key: key);

  @override
  State<ContentAppealScreen> createState() => _ContentAppealScreenState();
}

class _ContentAppealScreenState extends State<ContentAppealScreen> with AfterFirstLayoutMixin{

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    final notifier = Provider.of<TicketHistoryNotifier>(context, listen: false);
    notifier.startLoad();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange && notifier.hasNextAppeal) {
        notifier.onLoadAppealList(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final notifier = Provider.of<TicketHistoryNotifier>(context, listen: false);
    notifier.initContentAppeal(context);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<TicketHistoryNotifier>(context);
    return !notifier.isLoadingInit ? notifier.appealLength != 0 ? RefreshIndicator(
      strokeWidth: 2.0,
      color: Colors.purple,
      onRefresh: () async { notifier.initContentAppeal(context, isRefresh: true); },
      child: ListView.builder(
          itemCount: notifier.appealLength,
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if(index == notifier.listAppeals.length){
              return const Center(child: CustomLoading());
            }else{
              return ItemContentAppeal(data: notifier.listAppeals[index], model: notifier.language, isFirst: index == 0,);
            }
          }),
    ) : const NoResultFound(): ListView.builder(
        itemCount: 15,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomShimmer(
              radius: 8,
              height: 100,
              width: double.infinity,
            ),
          );
        });
  }
}
