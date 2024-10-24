import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  final String labelText;
  final TextStyle? labelStyle;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final Widget? suffixIcon;
  final double? suffixIconSize;
  final Widget? prefixIcon;
  final double? prefixIconSize;
  final bool readOnly;
  final Color? borderColor;
  final Function()? onTap;
  final FocusNode? focusNode;
  final Function(String)? onChange;
  final String? onChangeValue;
  final bool obscure;
  final EdgeInsets? contentPadding;
  final String? errorText;
  final double? inputAreaHeight;
  const SignUpForm(
      {Key? key,
      required this.labelText,
      required this.textEditingController,
      this.focusNode,
      this.labelStyle,
      this.textInputType = TextInputType.text,
      this.contentPadding,
      this.readOnly = false,
      this.obscure = false,
      this.borderColor,
      this.suffixIcon,
      this.suffixIconSize,
      this.prefixIcon,
      this.prefixIconSize,
      this.onTap,
      this.onChange,
      this.onChangeValue,
      this.errorText,
      this.inputAreaHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SignUpForm');
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: (onChangeValue ?? "") != ""
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        child: CustomTextFormField(
          inputAreaWidth: SizeConfig.screenWidth!,
          inputAreaHeight: inputAreaHeight ?? 50,
          focusNode: focusNode,
          obscuringCharacter: '*',
          onChanged: onChange,
          obscureText: obscure,
          textEditingController: textEditingController,
          textInputType: textInputType,
          onTap: onTap,
          readOnly: readOnly,
          inputDecoration: InputDecoration(
              contentPadding: contentPadding ?? const EdgeInsets.only(top: 0),
              labelText: labelText,
              labelStyle:
                  Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                        color: (focusNode?.hasPrimaryFocus ?? false) ||
                                (onChangeValue ?? "").isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
              prefixIconConstraints: BoxConstraints(
                  minWidth: prefixIcon != null
                      ? SizeWidget().calculateSize(
                          30, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)
                      : 0),
              suffixIconConstraints: BoxConstraints(
                  minWidth: suffixIcon != null
                      ? SizeWidget().calculateSize(
                          30, SizeWidget.baseWidthXD, SizeConfig.screenWidth!)
                      : 0),
              prefixIcon: prefixIcon != null
                  ? Transform.translate(
                      offset: Offset(
                          SizeWidget().calculateSize(-5.0,
                              SizeWidget.baseWidthXD, SizeConfig.screenWidth!),
                          0),
                      child: Transform.scale(
                        scale: SizeWidget().calculateSize(1.2,
                            SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                        child: prefixIcon,
                      ),
                    )
                  : const SizedBox.shrink(),
              suffixIcon: suffixIcon != null
                  ? Transform.scale(
                      scale: SizeWidget().calculateSize(suffixIconSize ?? 1.2,
                          SizeWidget.baseHeightXD, SizeConfig.screenHeight!),
                      child: suffixIcon,
                    )
                  : const SizedBox.shrink(),
              errorText: errorText),
        ),
      ),
    );
  }
}
