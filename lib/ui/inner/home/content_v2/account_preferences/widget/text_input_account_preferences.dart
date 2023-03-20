import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TextInputAccountPreferences extends StatelessWidget {
  final Function? onTap;
  final String? hintText;
  final String? labelText;
  final bool readOnly;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatter;
  final int? maxLength;
  final int? minLines;
  final double? inputAreaHeight;
  final bool keyboardNewline;
  final bool counterText;
  final TextInputType textInput;
  const TextInputAccountPreferences(
      {this.onTap,
      this.hintText,
      this.labelText,
      this.readOnly = false,
      this.controller,
      this.inputFormatter,
      this.maxLength,
      this.minLines,
      this.inputAreaHeight,
      this.keyboardNewline = false,
      this.counterText = true,
      this.textInput = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ProofPicture');
    if (controller != null) {
      return Consumer<AccountPreferencesNotifier>(
        builder: (_, notifier, __) => Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * SizeConfig.scaleDiagonal),
          child: CustomTextFormField(
            onTap: onTap as void Function()?,
            style: notifier.text(context),
            onChanged: (v) => notifier.notifyNotifier(),
            readOnly: readOnly,
            textAlign: TextAlign.left,
            inputFormatter: inputFormatter,
            textInputType: textInput,
            // textInputType: keyboardNewline ? TextInputType.multiline : TextInputType.text,
            textEditingController: controller!,
            inputDecoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
              hintStyle: notifier.hint(context),
              labelStyle: notifier.label(context),
              enabledBorder:
                  UnderlineInputBorder(borderSide: BorderSide(color: controller == null || controller!.text.isEmpty ? Theme.of(context).iconTheme.color ?? Colors.white : kHyppePrimary, width: 0.2)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff822E6E), width: 0.1)),
              contentPadding: const EdgeInsets.only(bottom: 2),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              counterText: counterText ? null : '',
            ),
            inputAreaWidth: SizeConfig.screenWidth!,
            inputAreaHeight: inputAreaHeight == null ? 50 * SizeConfig.scaleDiagonal : inputAreaHeight ?? 0,
            maxLength: maxLength,
            maxLines: 20,
            minLines: 1,
            textInputAction: keyboardNewline ? TextInputAction.newline : TextInputAction.next,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
