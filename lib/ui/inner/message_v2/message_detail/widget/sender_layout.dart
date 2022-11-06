import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';

import 'package:hyppe/core/services/system.dart';

import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/content_message_layout.dart';

class SenderLayout extends StatelessWidget {
  final DisqusLogs? chatData;

  const SenderLayout({Key? key, this.chatData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          topRight: Radius.zero,
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: SizeConfig.screenWidth! * 0.7,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if ((chatData?.content.isNotEmpty ?? false))
              ContentMessageLayout(
                message: chatData,
              ),
            CustomTextWidget(
              // textToDisplay: chatData.message,
              textAlign: TextAlign.start,
              textOverflow: TextOverflow.clip,
              textStyle: Theme.of(context).textTheme.bodyText2,
              textToDisplay: chatData?.txtMessages ?? chatData?.reactionIcon ?? '',
            ),
            CustomTextWidget(
              textAlign: TextAlign.end,
              textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(chatData?.createdAt ?? '', 1),
              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
