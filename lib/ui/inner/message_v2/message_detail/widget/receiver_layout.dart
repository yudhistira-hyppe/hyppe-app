import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/core/models/collection/message_v2/message_data_v2.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/content_message_layout.dart';

class ReceiverLayout extends StatelessWidget {
  final DisqusLogs? chatData;
  final String? created;

  const ReceiverLayout({Key? key, this.chatData, this.created}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.zero,
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: SizeConfig.screenWidth! * 0.7,
      ),
      child: Padding(
        padding: EdgeInsets.all(10 * SizeConfig.scaleDiagonal),
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
              textStyle: TextStyle(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 10),
              textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(chatData?.createdAt ?? '', 1),
              // textToDisplay: chatData?.createdAt == null ? "" : System().dateFormatter(created ?? '', 1),
            ),
          ],
        ),
      ),
    );
  }
}
