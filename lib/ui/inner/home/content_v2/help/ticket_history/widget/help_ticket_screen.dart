import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/widget/item_ticket_history.dart';
import 'package:provider/provider.dart';

import '../../../../../../constant/widget/custom_text_widget.dart';
import '../notifier.dart';

class HelpTicketScreen extends StatefulWidget {
  const HelpTicketScreen({Key? key}) : super(key: key);

  @override
  State<HelpTicketScreen> createState() => _HelpTicketScreenState();
}

class _HelpTicketScreenState extends State<HelpTicketScreen> with AfterFirstLayoutMixin{

  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    final notifier = Provider.of<TicketHistoryNotifier>(context, listen: false);
    notifier.startLoad();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange && notifier.hasNextTicket) {
        notifier.onLoadList(context);
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
    notifier.initHelpTicket(context);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<TicketHistoryNotifier>(context);
    return !notifier.isLoadingInit ? notifier.ticketLenght != 0 ? ListView.builder(
        itemCount: notifier.ticketLenght,
        controller: _scrollController,
        itemBuilder: (context, index) {
          if(index == notifier.listTickets.length){
            return const Center(child: CustomLoading());
          }else{
            return ItemTicketHistory(data: notifier.listTickets[index], model: notifier.language);
          }
        }) : Center(
      child: CustomTextWidget(textToDisplay: notifier.language.noData ?? ''),
    ): ListView.builder(
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
