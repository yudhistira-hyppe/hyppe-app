import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';

import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Function? onPressedIcon;
  final TextEditingController? controller;
  final Function()? onTap;
  final FocusNode? focusNode;
  final TextInputType textInputType;
  final TextAlign textAlign;
  final String? hintText;
  final double? heightText;
  final InputDecoration? inputDecoration;
  final EdgeInsetsGeometry? contentPadding;
  final bool readOnly;
  
  const CustomSearchBar({
    Key? key,
    this.onSubmitted,
    this.onChanged,
    this.controller,
    this.onTap,
    this.hintText,
    this.contentPadding,
    this.onPressedIcon,
    this.heightText,
    this.focusNode,
    this.inputDecoration,
    this.textInputType = TextInputType.text,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.all(Radius.circular(4))),
      child: TextField(
        readOnly: readOnly,
        focusNode: focusNode,
        controller: controller,
        decoration: inputDecoration ?? InputDecoration(
            prefixIcon: CustomIconButtonWidget(
              defaultColor: false,
              onPressed: onPressedIcon,
              iconData: "${AssetPath.vectorPath}search.svg",
            ),
            hintStyle: Theme.of(context).textTheme.subtitle2,
            hintText: hintText,
            contentPadding: contentPadding,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            counterText: ''),
        textInputAction: TextInputAction.search,
        maxLines: 1,
        textAlign: textAlign,
        keyboardType: textInputType,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}