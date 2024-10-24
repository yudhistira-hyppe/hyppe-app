// ignore_for_file: prefer_contains

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdvanceTextWidget extends StatelessWidget {
  final Color? clickColor;
  final Function()? onTap;
  final TextStyle? textStyle;
  final String textToDisplay;
  final int? maxLines;
  final TextAlign textAlign;
  final TextOverflow? textOverflow;

  const AdvanceTextWidget({
    Key? key,
    this.onTap,
    this.textStyle,
    this.clickColor,
    required this.textToDisplay,
    this.maxLines,
    this.textOverflow,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _filterMentionTextAndCombineWithPart(textToDisplay, theme);
  }

  Widget _filterMentionTextAndCombineWithPart(String input, ThemeData theme) {
    List<TextSpan> textSpans = [];

    final RegExp regExp = RegExp(r'@[a-zA-Z0-9_]+');

    final matches = regExp.allMatches(input);

    // get all mention text
    for (var match in matches) {
      final mentionText = input.substring(match.start, match.end);

      // get mention text
      final mentionTextSpan = TextSpan(
        text: mentionText,
        style: textStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: clickColor ?? theme.colorScheme.primary,
            ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // log.d('onTap mention text: $mentionText');
          },
      );

      // get part text
      final partText = input.substring(match.end);

      // add mention text to text spans
      textSpans.add(mentionTextSpan);

      // add part text to text spans
      textSpans.add(TextSpan(
        text: partText,
        style: textStyle ?? theme.textTheme.bodyLarge,
      ));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
      ),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: textOverflow ?? TextOverflow.ellipsis,
    );
  }
}
