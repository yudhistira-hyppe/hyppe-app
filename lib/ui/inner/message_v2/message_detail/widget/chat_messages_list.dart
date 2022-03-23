import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/constants/file_extension.dart';
// import 'package:hyppe/core/constants/thumb/profile_image.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';

import 'package:hyppe/ui/inner/message_v2/message_detail/notifier.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/sender_layout.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/receiver_layout.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({Key? key}) : super(key: key);

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  @override
  void initState() {
    final _notifier = Provider.of<MessageDetailNotifier>(context, listen: false);
    _notifier.scrollController.addListener(() => _notifier.scrollListener(context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageDetailNotifier>(
      builder: (_, notifier, __) => Flexible(
        child: (notifier.discussData?.isEmpty ?? true)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomProfileImage(
                    width: 80,
                    height: 80,
                    following: true,
                    imageUrl: notifier.argument.photoReceiver,
                    // imageUrl:
                    //     '${notifier.photoUrl!.endsWith(JPG) || notifier.photoUrl!.endsWith(JPEG) ? notifier.photoUrl! : notifier.photoUrl! + SMALL}',
                  ),
                  twentyPx,
                  CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.subtitle1,
                    textToDisplay: "${notifier.argument.fullnameReceiver} is on Hyppe! let's say hello🔥",
                  ),
                ],
              )
            : ListView.builder(
                reverse: true,
                controller: notifier.scrollController,
                // itemCount: notifier.listChatData.length,
                itemCount: notifier.discussData?.first.disqusLogs.length,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 10 * SizeConfig.scaleDiagonal,
                  left: 13 * SizeConfig.scaleDiagonal,
                  right: 8 * SizeConfig.scaleDiagonal,
                  bottom: 10 * SizeConfig.scaleDiagonal,
                ),
                itemBuilder: (context, index) {
                  final discussLogs = notifier.discussData?.first.disqusLogs[index];

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        // child: Row(
                        //   mainAxisAlignment:
                        //       notifier.listChatData[index].senderID == notifier.senderID ? MainAxisAlignment.end : MainAxisAlignment.start,
                        //   children: <Widget>[
                        //     notifier.listChatData[index].senderID == notifier.senderID
                        //         ? Flexible(child: SenderLayout(chatData: notifier.listChatData[index]))
                        //         : Flexible(child: ReceiverLayout(chatData: notifier.listChatData[index]))
                        //   ],
                        // ),
                        child: Row(
                          mainAxisAlignment: notifier.isMyMessage(discussLogs?.sender) ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: <Widget>[
                            notifier.isMyMessage(discussLogs?.sender)
                                ? Flexible(child: SenderLayout(chatData: discussLogs))
                                : Flexible(child: ReceiverLayout(chatData: discussLogs))
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
