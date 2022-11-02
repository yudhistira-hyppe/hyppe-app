import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
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
  final double contentPadding;
  const SignUpForm({
    Key? key,
    required this.labelText,
    required this.textEditingController,
    this.focusNode,
    this.labelStyle,
    this.textInputType = TextInputType.text,
    this.contentPadding = 0,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: (onChangeValue ?? "") != "" ? Theme.of(context).colorScheme.primaryVariant : Theme.of(context).colorScheme.secondaryVariant,
              ),
            ),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryVariant)),
          ),
        ),
        child: CustomTextFormField(
          inputAreaWidth: SizeConfig.screenWidth!,
          inputAreaHeight: 50,
          focusNode: focusNode,
          obscuringCharacter: '*',
          onChanged: onChange,
          obscureText: obscure,
          textEditingController: textEditingController,
          textInputType: textInputType,
          onTap: onTap,
          readOnly: readOnly,
          inputDecoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: contentPadding),
            labelText: labelText,
            labelStyle: Theme.of(context).primaryTextTheme.bodyText1!.copyWith(
                  color:
                      (focusNode?.hasPrimaryFocus ?? false) || (onChangeValue ?? "").isNotEmpty ? Theme.of(context).colorScheme.primaryVariant : null,
                ),
            prefixIconConstraints:
                BoxConstraints(minWidth: prefixIcon != null ? SizeWidget().calculateSize(30, SizeWidget.baseWidthXD, SizeConfig.screenWidth!) : 0),
            suffixIconConstraints:
                BoxConstraints(minWidth: suffixIcon != null ? SizeWidget().calculateSize(30, SizeWidget.baseWidthXD, SizeConfig.screenWidth!) : 0),
            prefixIcon: prefixIcon != null
                ? Transform.translate(
                    offset: Offset(SizeWidget().calculateSize(-5.0, SizeWidget.baseWidthXD, SizeConfig.screenWidth!), 0),
                    child: Transform.scale(
                      scale: SizeWidget().calculateSize(1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight ?? context.getHeight()),
                      child: prefixIcon,
                    ),
                  )
                : const SizedBox.shrink(),
            suffixIcon: suffixIcon != null
                ? Transform.scale(
                    scale: SizeWidget().calculateSize(suffixIconSize ?? 1.2, SizeWidget.baseHeightXD, SizeConfig.screenHeight ?? context.getHeight()),
                    child: suffixIcon,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
