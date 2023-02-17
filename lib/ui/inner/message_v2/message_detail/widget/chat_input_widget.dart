import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/ui/inner/message_v2/message_detail/notifier.dart';

class ChatInputWidget extends StatelessWidget {
  const ChatInputWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<MessageDetailNotifier, TranslateNotifierV2>(
      builder: (_, notifier, notifier2, __) => Container(
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsets.all(16 * SizeConfig.scaleDiagonal),
        width: SizeConfig.screenWidth,
        child: TextField(
          minLines: 1,
          maxLines: 7,
          style: Theme.of(context).textTheme.bodyText2,
          controller: notifier.messageController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.send,
          keyboardAppearance: Brightness.dark,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.background,
            hintText: "${notifier2.translate.typeAMessage}...",
            hintStyle: const TextStyle(color: Color(0xffBABABA), fontSize: 14),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
            // prefixIcon: CustomIconButtonWidget(
            //   iconData: "${AssetPath.vectorPath}storage.svg",
            //   onPressed: () => notifier.onTapLocalMedia(context),
            // ),
            suffixIcon: notifier.messageController.text.isNotEmpty
                ? CustomTextButton(
                    child: CustomTextWidget(
                      textToDisplay: notifier2.translate.send ?? 'Send',
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () => notifier.sendMessage(context),
                  )
                : const SizedBox.shrink(),
          ),
          onChanged: (value) => notifier.onChangeHandler(value),
          onSubmitted: (value) => notifier.sendMessage(context),
        ),
      ),
    );
  }
}
