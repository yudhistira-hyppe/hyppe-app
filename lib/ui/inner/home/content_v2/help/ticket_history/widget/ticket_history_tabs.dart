import 'package:flutter/material.dart';
import 'package:hyppe/ui/inner/home/content_v2/help/ticket_history/notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/constants/size_config.dart';
import '../../../../../../constant/widget/custom_text_button.dart';
import '../../../../../../constant/widget/custom_text_widget.dart';

class TicketHistoryTabsScreen extends StatelessWidget {
  const TicketHistoryTabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<TicketHistoryNotifier>(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomTextWidget(
                      textAlign: TextAlign.center,
                      textToDisplay: notifier.language.help ?? 'Help',
                      textStyle: TextStyle(fontSize: 14, color: notifier.isHelpTab ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor),
                    ),
                  ],
                ),
                onPressed: () => notifier.isHelpTab = true,
              ),
              SizedBox(
                height: 2 * SizeConfig.scaleDiagonal,
                width: 125 * SizeConfig.scaleDiagonal,
                child: Container(color: notifier.isHelpTab ? Theme.of(context).colorScheme.primary : null),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomTextWidget(
                      textAlign: TextAlign.center,
                      textToDisplay: notifier.language.contentAppeal ?? 'Content Appeal',
                      textStyle: TextStyle(fontSize: 14, color: !notifier.isHelpTab ? Theme.of(context).colorScheme.primary : Theme.of(context).tabBarTheme.unselectedLabelColor),
                    ),
                  ],
                ),
                onPressed: () => notifier.isHelpTab = false,
              ),
              SizedBox(
                height: 2 * SizeConfig.scaleDiagonal,
                width: 125 * SizeConfig.scaleDiagonal,
                child: Container(color: !notifier.isHelpTab ? Theme.of(context).colorScheme.primary : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
