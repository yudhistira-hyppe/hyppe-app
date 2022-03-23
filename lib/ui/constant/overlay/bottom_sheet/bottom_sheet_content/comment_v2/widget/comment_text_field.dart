import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/initial/hyppe/translate_v2.dart';

import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/entities/comment_v2/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class CommentTextField extends StatelessWidget {
  final bool fromFront;

  const CommentTextField({
    Key? key,
    required this.fromFront,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<CommentNotifierV2, TranslateNotifierV2>(
      builder: (_, notifier, language, __) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            child: child,
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
          );
        },
        child: !fromFront
            ? _buildTextInput(notifier, language, context)
            : notifier.commentController.text.isNotEmpty || notifier.showTextInput
                ? _buildTextInput(notifier, language, context)
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildTextInput(CommentNotifierV2 notifier, TranslateNotifierV2 language, BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: SizeConfig.screenWidth,
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surface,
          child: TextFormField(
            minLines: 1,
            maxLines: 7,
            focusNode: notifier.inputNode,
            keyboardType: TextInputType.text,
            keyboardAppearance: Brightness.dark,
            controller: notifier.commentController,
            textInputAction: TextInputAction.unspecified,
            style: Theme.of(context).textTheme.bodyText2,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              hintText: "${language.translate.typeAMessage}...",
              hintStyle: const TextStyle(color: Color(0xffBABABA), fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
              suffixIcon: notifier.commentController.text.isNotEmpty
                  ? notifier.loading
                      ? const CustomLoading(size: 4)
                      : CustomTextButton(
                          child: CustomTextWidget(
                            textToDisplay: language.translate.send!,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.primaryVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            notifier.addComment(context);
                          },
                        )
                  : const SizedBox.shrink(),
            ),
            onChanged: (value) => notifier.onChangeHandler(value),
          ),
        ),
      ),
    );
  }
}
