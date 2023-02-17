import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/widget/content_appeal_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/widget/help_ticket_screen.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/widget/ticket_history_tabs.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/arguments/ticket_argument.dart';
import '../../../../../../core/constants/asset_path.dart';
import '../../../../../../core/constants/size_config.dart';
import '../../../../../../ux/routing.dart';
import '../../../../../constant/widget/custom_text_widget.dart';
import '../../../../../constant/widget/icon_button_widget.dart';

class TicketHistoryScreen extends StatefulWidget {
  final TicketArgument data;
  const TicketHistoryScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {

  @override
  void initState() {
    context.read<TicketHistoryNotifier>().startOpenHistory(widget.data.values ?? []);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<TicketHistoryNotifier>(
      builder: (context, notifier, _){
        return Scaffold(
          appBar: AppBar(
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () => Routing().moveBack(),
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: notifier.language.ticketHistory ?? 'Ticket History',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
            ),
            centerTitle: false,),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TicketHistoryTabsScreen(),
              Expanded(child: notifier.isHelpTab ? HelpTicketScreen() : ContentAppealScreen())
            ],
          ),
        );
      },
    );
  }


}
