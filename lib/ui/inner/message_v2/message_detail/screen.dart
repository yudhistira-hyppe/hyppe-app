import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/core/arguments/message_detail_argument.dart';

import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_profile_image.dart';
import 'package:hyppe/ui/constant/widget/story_color_validator.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';

import 'package:hyppe/ui/inner/message_v2/message_detail/notifier.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/chat_input_widget.dart';
import 'package:hyppe/ui/inner/message_v2/message_detail/widget/chat_messages_list.dart';

class MessageDetailScreen extends StatefulWidget {
  final MessageDetailArgument argument;

  // ignore: use_key_in_widget_constructors
  const MessageDetailScreen({required this.argument});

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notifier = MessageDetailNotifier();

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MessageDetailScreen');
    // Provider.of<MessageDetailNotifier>(context, listen: false).initialData(context, _scrollController);
    _notifier.initState(context, widget.argument);
    // _scrollController.addListener(() => _notifier.scrollListener(context, _scrollController));

    super.initState();
  }

  @override
  void dispose() {
    _notifier.disposeNotifier();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ChangeNotifierProvider<MessageDetailNotifier>(
      create: (context) => _notifier,
      child: Consumer<MessageDetailNotifier>(
        builder: (_, notifier, __) => GestureDetector(
          child: Scaffold(
            appBar: notifier.selectData < 0
                ? AppBar(
                    centerTitle: false,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    leading: BackButton(
                      onPressed: () => notifier.onBack(),
                    ),
                    title: InkWell(
                      onTap: () => System().navigateToProfile(context, notifier.argument.emailReceiver),
                      child: Row(
                        children: [
                          StoryColorValidator(
                            featureType: FeatureType.other,
                            // haveStory: notifier.isHaveStory,
                            haveStory: false,
                            child: CustomProfileImage(
                              width: 35,
                              height: 35,
                              following: true,
                              imageUrl: notifier.argument.photoReceiver,
                              badge: notifier.argument.badgeReceiver,
                              // imageUrl:
                              //     notifier.photoUrl.endsWith(JPG) || notifier.photoUrl.endsWith(JPEG) ? notifier.photoUrl : notifier.photoUrl + SMALL,
                            ),
                          ),
                          sixteenPx,
                          CustomRichTextWidget(
                            textSpan: TextSpan(
                              style: Theme.of(context).textTheme.subtitle2,
                              text: "${notifier.argument.usernameReceiver}\n",
                              children: <TextSpan>[
                                TextSpan(
                                  text: notifier.argument.fullnameReceiver,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                )
                              ],
                            ),
                            textAlign: TextAlign.start,
                            textStyle: Theme.of(context).textTheme.overline,
                          ),
                        ],
                      ),
                    ),
                  )
                : AppBar(
                    centerTitle: false,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    leading: BackButton(
                      onPressed: () => notifier.selectData = -1,
                    ),
                    actions: [
                        InkWell(
                          onTap: () {
                            notifier.deleteChat(context);
                          },
                          child: const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}delete.svg",
                          ),
                        ),
                        fifteenPx
                      ]),
            body: Form(
              key: _formKey,
              onWillPop: () async {
                notifier.onBack();
                return false;
              },
              // child: notifier.senderID == null
              //     ? Container(child: const CustomLoading())
              //     : Column(
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: <Widget>[
              //           SizedBox.shrink(),
              //           ChatMessageList(scrollController: _scrollController),
              //           ChatInputWidget(_scrollController),
              //         ],
              //       ),
              child: notifier.discussData == null
                  ? const Center(child: CustomLoading())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: const <Widget>[
                        // SizedBox.shrink(),
                        // ChatMessageList(scrollController: _scrollController),
                        // ChatInputWidget(_scrollController),
                        ChatMessageList(),
                        ChatInputWidget(),
                      ],
                    ),
            ),
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).colorScheme.background,
          ),
          onTap: () => notifier.closeKeyboard(context),
        ),
      ),
    );
  }
}
