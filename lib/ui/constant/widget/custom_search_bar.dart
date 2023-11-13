import 'package:flutter/material.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';

import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Function()? onPressedIcon;
  final Function()? onPressedRightIcon;
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
  final bool autoFocus;
  final bool withShadow;

  const CustomSearchBar({
    Key? key,
    this.onSubmitted,
    this.onChanged,
    this.controller,
    this.onTap,
    this.hintText,
    this.contentPadding,
    this.onPressedIcon,
    this.onPressedRightIcon,
    this.heightText,
    this.focusNode,
    this.inputDecoration,
    this.textInputType = TextInputType.text,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.autoFocus = false,
    this.withShadow = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.background,
          boxShadow: withShadow ? const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 7)] : null,
          borderRadius: const BorderRadius.all(Radius.circular(4))),
      child: TextField(
        readOnly: readOnly,
        focusNode: focusNode,
        controller: controller,
        autofocus: autoFocus,
        style: Theme.of(context).textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w400),
        decoration: inputDecoration ??
            InputDecoration(
              suffixIcon: onPressedRightIcon != null ? CustomIconButtonWidget(
                defaultColor: false,
                onPressed: onPressedRightIcon,
                iconData: "${AssetPath.vectorPath}filter.svg",
              ) : null,
                prefixIcon: CustomIconButtonWidget(
                  height: 24,
                  defaultColor: false,
                  onPressed: onPressedIcon,
                  iconData: "${AssetPath.vectorPath}search.svg",
                ),
                hintStyle: Theme.of(context).textTheme.bodyText2?.copyWith(color: kHyppeBurem),
                hintText: hintText,
                contentPadding: contentPadding,
                border: InputBorder.none,
                // focusedBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: kHyppePrimary),
                ),
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
