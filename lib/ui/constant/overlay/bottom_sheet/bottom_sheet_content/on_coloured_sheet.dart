import 'dart:async';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class OnColouredSheet extends StatefulWidget {
  final int? maxLines;
  final String? iconSvg;
  final String? caption;
  final double? sizeIcon;
  final String? subCaption;
  final bool fromSnackBar;
  final Color? iconColor;
  final Color? textColor;
  final Color? textButtonColor;
  final String? textButton;
  final Function? function;
  final Function()? functionSubCaption;
  final String? subCaptionButton;
  final TextOverflow? textOverflow;
  final int? milisecond;
  final bool isArrow;
  final bool isMargin;
  final Widget? closeWidget;
  const OnColouredSheet({
    Key? key,
    required this.caption,
    this.subCaption,
    this.subCaptionButton,
    this.iconSvg,
    this.sizeIcon,
    this.maxLines,
    this.fromSnackBar = false,
    this.iconColor,
    this.textColor = kHyppeLightButtonText,
    this.textButtonColor = kHyppeLightButtonText,
    this.textButton,
    this.function,
    this.textOverflow,
    this.functionSubCaption,
    this.milisecond,
    this.isArrow = false,
    this.isMargin = false,
    this.closeWidget,
  }) : super(key: key);

  @override
  _OnColouredSheetState createState() => _OnColouredSheetState();
}

class _OnColouredSheetState extends State<OnColouredSheet> {
  final ValueNotifier<bool> _loading = ValueNotifier(false);
  bool close = false;

  void _conditionalFunction() async {
    if (widget.function == null) {
      widget.fromSnackBar
          ? Routing().removeSnackBar()
          : Navigator.pop<bool>(context, true);
    } else {
      try {
        _loading.value = true;
        if (widget.function != null) {
          await widget.function!();
        }
        _loading.value = false;
      } catch (_) {
      } finally {
        if (mounted) {
          widget.fromSnackBar
              ? Routing().removeSnackBar()
              : Navigator.pop<bool>(context, true);
        }
      }
    }
  }

  @override
  void initState() {
    if (widget.milisecond != null) {
      Timer(Duration(milliseconds: widget.milisecond ?? 0), () {
        if (!close) {
          Routing().moveBack();
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    close = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return widget.isMargin
        ? _withMargin()
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      sixteenPx,
                      CustomIconWidget(
                        iconData: widget.iconSvg ??
                            "${AssetPath.vectorPath}valid-invert.svg",
                        defaultColor: false,
                        height: widget.sizeIcon,
                        width: widget.sizeIcon,
                        color: widget.iconColor,
                      ),
                      eightPx,
                      SizedBox(
                        width: MediaQuery.of(context).size.width -
                            (16 +
                                8 +
                                14 +
                                ((widget.textButton?.length ?? 0) <= 2
                                    ? 60
                                    : 90)),
                        child: CustomTextWidget(
                          maxLines: widget.maxLines,
                          textOverflow: widget.textOverflow,
                          textToDisplay: widget.caption ?? '',
                          textAlign: TextAlign.left,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: widget.textColor),
                        ),
                      )
                    ],
                  ),
                  widget.subCaption != null
                      ? Row(
                          children: [
                            GestureDetector(
                              onTap: widget.functionSubCaption,
                              child: Container(
                                  width: SizeConfig.screenWidth,
                                  padding: const EdgeInsets.only(
                                      left: 40, bottom: 10, top: 6),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "${widget.subCaption} ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: widget.textColor),
                                      children: [
                                        widget.subCaptionButton != null
                                            ? TextSpan(
                                                text:
                                                    '${widget.subCaptionButton}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: widget.textColor,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                              )
                                            : const TextSpan()
                                      ],
                                    ),
                                  )
                                  //        CustomTextWidget(
                                  //         maxLines: widget.maxLines,
                                  //         textToDisplay: widget.subCaption ?? '',
                                  //         textOverflow: TextOverflow.visible,
                                  //         textAlign: TextAlign.left,
                                  //         textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: kHyppeLightButtonText),
                                  //       ),
                                  ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
              widget.subCaption != null
                  ? const SizedBox.shrink()
                  : Container(
                      padding: EdgeInsets.only(
                          right:
                              (widget.textButton?.length ?? 0) <= 2 ? 0 : 10),
                      width: (widget.textButton?.length ?? 0) <= 2 ? 50 : null,
                      height: 50,
                      child: CustomTextButton(
                        onPressed: () => _conditionalFunction(),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _loading,
                          builder: (_, value, __) {
                            if (value) {
                              return const SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CustomLoading());
                            }

                            return CustomTextWidget(
                              maxLines: 1,
                              textToDisplay: widget.textButton ?? 'Ok',
                              textAlign: TextAlign.right,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: widget.textButtonColor),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          );
  }

  Widget _withMargin() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.iconSvg != null)
          CustomIconWidget(
            iconData: widget.iconSvg!,
            defaultColor: false,
            height: widget.sizeIcon,
            width: widget.sizeIcon,
            color: widget.iconColor,
          ),
        if (widget.iconSvg != null) fourteenPx,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.caption != null)
                CustomTextWidget(
                  maxLines: widget.maxLines,
                  textOverflow: widget.textOverflow,
                  textToDisplay: widget.caption!,
                  textAlign: TextAlign.left,
                  textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: widget.textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              if (widget.subCaption != null)
                CustomTextWidget(
                  maxLines: widget.maxLines,
                  textOverflow: widget.textOverflow,
                  textToDisplay: widget.subCaption!,
                  textAlign: TextAlign.left,
                  textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: widget.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
            ],
          ),
        ),
        widget.closeWidget ?? const SizedBox(height: 0, width: 0),
        if (widget.isArrow)
          InkWell(
            onTap: () {
              if (widget.function != null) {
                widget.function!();
              }
            },
            child: const CustomIconWidget(
              iconData: "${AssetPath.vectorPath}arrow_right.svg",
              defaultColor: false,
              height: 20,
              width: 20,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
