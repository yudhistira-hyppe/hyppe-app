import 'package:flutter/material.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/widget/item_ticket_history.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/asset_path.dart';
import '../../../../../../../core/constants/themes/hyppe_colors.dart';
import '../../../../../../../core/models/collection/support_ticket/ticket_model.dart';
import '../../../../../../constant/widget/custom_icon_widget.dart';
import '../../../../../../constant/widget/custom_spacer.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';
import '../../../../../../constant/widget/no_result_found.dart';
import '../notifier.dart';

class HelpTicketScreen extends StatefulWidget {
  const HelpTicketScreen({Key? key}) : super(key: key);

  @override
  State<HelpTicketScreen> createState() => _HelpTicketScreenState();
}

class _HelpTicketScreenState extends State<HelpTicketScreen> with AfterFirstLayoutMixin{

  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _globalKey = GlobalKey<RefreshIndicatorState>();


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
    return !notifier.isLoadingInit ? notifier.ticketLenght != 0 ? RefreshIndicator(
      key: _globalKey,
      strokeWidth: 2.0,
      color: Colors.purple,
      onRefresh: () => notifier.initHelpTicket(context, isRefresh: true),
      child: notifier.showAllTickets ? Stack(
        children: [
          ListView.builder(
              itemCount: notifier.ticketLenght,
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                if(index == notifier.listTickets.length){
                  return const Center(child: CustomLoading());
                }else{
                  return ItemTicketHistory(data: notifier.listTickets[index], model: notifier.language, isFirst: index == 0);
                }
              }),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: (){
                notifier.showAllTickets = false;
              },
              child: Container(
                alignment: Alignment.center,
                width: 50,
                height: 50,
                child: const CustomIconWidget(iconData: '${AssetPath.vectorPath}back-arrow.svg', width: 35, height: 35, defaultColor: false, color: Colors.white,),
                decoration: BoxDecoration(boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 2)], borderRadius: const BorderRadius.all(Radius.circular(25)), color: kHyppePrimary.withOpacity(0.5)),
              ),
            ),
          )
        ],
      ) : _onProgressTicketLayout(notifier.onProgressTicket, notifier),
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

  Widget _onProgressTicketLayout(List<TicketModel> values, TicketHistoryNotifier notifier, ){
    final model = notifier.language;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: values.map((e){
              final index = values.indexOf(e);
              return ItemTicketHistory(data: e, model: model, isFirst: index == 0);
            }).toList(),
          ),

          // Expanded(
          //   child: ListView.builder(
          //       itemCount: values.length,
          //       physics: const AlwaysScrollableScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         return ItemTicketHistory(data: values[index], model: model, isFirst: index == 0);
          //       },
          //   ),
          // ),
          if(values.length == 10)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 13, right: 10, top: 10, bottom: 10),
            margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: kHyppeLightSurface, ),
            child: Row(
              children: [
                const CustomIconWidget(iconData: '${AssetPath.vectorPath}info-icon.svg', defaultColor: false, color: kHyppeLightSecondary,),
                twelvePx,
                CustomTextWidget(textToDisplay: model.messageMaxTickets ?? '', textStyle: const TextStyle(fontWeight: FontWeight.w400, color: kHyppeLightSecondary, fontSize: 12),)
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, bottom: 20),
            child: CustomTextButton(onPressed: (){
              notifier.showAllTickets = true;
            }, child: CustomTextWidget(textToDisplay: model.seeTicketHistory ?? '', textStyle: const TextStyle(color: kHyppePrimary, fontWeight: FontWeight.w700, fontSize: 14),)),
          )
        ],
      ),
    );
  }

}
