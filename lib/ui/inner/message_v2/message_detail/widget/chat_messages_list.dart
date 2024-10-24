import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
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
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ChatMessageList');
    final _notifier =
        Provider.of<MessageDetailNotifier>(context, listen: false);
    _notifier.scrollController
        .addListener(() => _notifier.scrollListener(context));
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
                    badge: notifier.argument.badgeReceiver,
                    // imageUrl:
                    //     '${notifier.photoUrl.endsWith(JPG) || notifier.photoUrl.endsWith(JPEG) ? notifier.photoUrl : notifier.photoUrl + SMALL}',
                  ),
                  twentyPx,
                  CustomTextWidget(
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textToDisplay:
                        "${notifier.argument.fullnameReceiver} is on Hyppe! let's say hello🔥",
                  ),
                ],
              )
            : ListView.builder(
                shrinkWrap: true,
                reverse: true,
                controller: notifier.scrollController,
                // itemCount: notifier.listChatData.length,
                itemCount: notifier.discussData?.first.disqusLogs.length,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 10 * SizeConfig.scaleDiagonal,
                  // left: 13 * SizeConfig.scaleDiagonal,
                  // right: 8 * SizeConfig.scaleDiagonal,
                  bottom: 10 * SizeConfig.scaleDiagonal,
                ),
                itemBuilder: (context, index) {
                  final discussLogs =
                      notifier.discussData?.first.disqusLogs[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          color: notifier.selectData == index
                              ? kHyppeBottomNavBarIcon
                              : Colors.transparent,
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 2, bottom: 2),
                          child: Row(
                            mainAxisAlignment:
                                notifier.isMyMessage(discussLogs?.sender)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: <Widget>[
                              notifier.isMyMessage(discussLogs?.sender)
                                  ? Flexible(
                                      child: InkWell(
                                          onLongPress: () {
                                            notifier.selectData = index;
                                          },
                                          child: SenderLayout(
                                            chatData: discussLogs,
                                          )))
                                  : Flexible(
                                      child: ReceiverLayout(
                                      chatData: discussLogs,
                                      // created: notifier.discussData?[index].createdAt,
                                    ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
