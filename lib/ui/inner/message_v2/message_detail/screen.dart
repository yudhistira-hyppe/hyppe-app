import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/size_config.dart';
// import 'package:hyppe/core/constants/file_extension.dart';
// import 'package:hyppe/core/constants/thumb/profile_image.dart';

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

  const MessageDetailScreen({required this.argument});

  @override
  _MessageDetailScreenState createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notifier = MessageDetailNotifier();

  @override
  void initState() {
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
            appBar: AppBar(
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
                        // imageUrl:
                        //     notifier.photoUrl!.endsWith(JPG) || notifier.photoUrl!.endsWith(JPEG) ? notifier.photoUrl! : notifier.photoUrl! + SMALL,
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
                              color: Theme.of(context).colorScheme.secondaryVariant,
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
              // actions: [
              //   IconButton(
              //     splashColor: Colors.transparent,
              //     icon: CustomIconWidget(iconData: "${AssetPath.vectorPath}more.svg", defaultColor: false),
              //     onPressed: () => print("User Menu"),
              //   ),
              // ],
            ),
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
                  ? Container(child: const CustomLoading())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const <Widget>[
                        SizedBox.shrink(),
                        // ChatMessageList(scrollController: _scrollController),
                        // ChatInputWidget(_scrollController),
                        ChatMessageList(),
                        ChatInputWidget(),
                      ],
                    ),
            ),
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onTap: () => notifier.closeKeyboard(context),
        ),
      ),
    );
  }
}
