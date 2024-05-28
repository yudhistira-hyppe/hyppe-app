import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class GeneralAlertDialog extends StatefulWidget {
  final String? titleText;
  final String? bodyText;
  final int? maxLineTitle;
  final int? maxLineBody;
  final Function functionPrimary;
  final Function? functionSecondary;
  final String? titleButtonPrimary;
  final String? titleButtonSecondary;
  final bool? isLoading;
  final bool isHorizontal;
  final bool fillColor;
  final Widget? bodyWidget;
  final Widget? topWidget;
  const GeneralAlertDialog(
      {Key? key,
      this.titleText,
      this.bodyText,
      this.maxLineTitle,
      this.maxLineBody,
      required this.functionPrimary,
      this.functionSecondary,
      this.titleButtonPrimary,
      this.titleButtonSecondary,
      this.isLoading = false,
      this.isHorizontal = true,
      this.bodyWidget,
      this.topWidget,
      this.fillColor = true})
      : super(key: key);

  @override
  State<GeneralAlertDialog> createState() => _GeneralAlertDialogState();
}

class _GeneralAlertDialogState extends State<GeneralAlertDialog> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final size = MediaQuery.of(context).size;
    // final _language = context.watch<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          widget.topWidget ?? SizedBox.shrink(),
          CustomTextWidget(
            textToDisplay: '${widget.titleText}',
            maxLines: widget.maxLineTitle,
            textStyle: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w600),
          ),
          twelvePx,
          Visibility(
            visible: widget.bodyText != null || widget.bodyText != '',
            child: CustomTextWidget(
              maxLines: widget.maxLineBody,
              textOverflow: TextOverflow.visible,
              textToDisplay: '${widget.bodyText}',
              textStyle: theme.textTheme.bodyText2,
            ),
          ),
          widget.bodyWidget ?? const SizedBox.shrink(),
          widget.bodyText == null || widget.bodyText == '' ? const SizedBox.shrink() : twelvePx,
          widget.bodyText == null || widget.bodyText == '' ? const SizedBox.shrink() : twelvePx,
          _isLoading
              ? const CustomLoading()
              : widget.isHorizontal
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        widget.functionSecondary == null
                            ? Container()
                            : Expanded(
                                child: _buildButton(
                                  caption: '${widget.titleButtonSecondary}',
                                  color: Colors.transparent,
                                  function: widget.functionSecondary ?? () {},
                                  textColor: theme.colorScheme.primary,
                                  // function: () => _routing.moveBack(),
                                  theme: theme,
                                ),
                              ),
                        Expanded(
                          child: _buildButton(
                            caption: '${widget.titleButtonPrimary}',
                            textColor: kHyppeLightButtonText,
                            color: theme.colorScheme.primary,
                            function: widget.functionPrimary,
                            // function: () => widget.function(),
                            theme: theme,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton(
                          caption: '${widget.titleButtonPrimary}',
                          textColor: widget.fillColor ? kHyppeLightButtonText : kHyppePrimary,
                          color: widget.fillColor ? theme.colorScheme.primary : Colors.transparent,
                          function: widget.functionPrimary,
                          matchParent: true,
                          // function: () => widget.function(),
                          theme: theme,
                        ),
                        eightPx,
                        widget.functionSecondary == null
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  if (widget.functionSecondary != null) {
                                    widget.functionSecondary!();
                                  }
                                },
                                child: CustomTextWidget(
                                  textToDisplay: '${widget.titleButtonSecondary}',
                                  textStyle: theme.textTheme.button?.copyWith(color: theme.colorScheme.primary, fontSize: 14),
                                ),
                              ),
                        eightPx
                      ],
                    )
        ],
      ),
    );
  }

  Widget _buildButton({required ThemeData theme, required String caption, required Function function, required Color color, Color? textColor, bool matchParent = false}) {
    return CustomTextButton(
      onPressed: () async {
        try {
          setState(() => _isLoading = true);
          await function();
          setState(() => _isLoading = false);
        } catch (_) {
          setState(() => _isLoading = false);
        }
      },
      child: matchParent
          ? Container(
              width: double.infinity,
              child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button?.copyWith(color: textColor, fontSize: 14)),
            )
          : CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button?.copyWith(color: textColor, fontSize: 14)),
      style: theme.elevatedButtonTheme.style?.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );

    // return CustomElevatedButton(
    //   child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button?.copyWith(color: textColor, fontSize: 10)),
    //   width: 120,
    //   height: 42,
    //   function: () {
    //     try {
    //       function();
    //     } catch (_) {}
    //   },
    //   buttonStyle: theme.elevatedButtonTheme.style?.copyWith(
    //     backgroundColor: MaterialStateProperty.all(color),
    //   ),
    // );
  }
}
