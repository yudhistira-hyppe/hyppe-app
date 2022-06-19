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
  final String caption;
  final double? sizeIcon;
  final String? subCaption;
  final bool fromSnackBar;
  final Color? iconColor;
  final Function? function;
  final TextOverflow? textOverflow;
  const OnColouredSheet({
    Key? key,
    required this.caption,
    this.subCaption,
    this.iconSvg,
    this.sizeIcon,
    this.maxLines,
    this.fromSnackBar = false,
    this.iconColor,
    this.function,
    this.textOverflow,
  }) : super(key: key);

  @override
  _OnColouredSheetState createState() => _OnColouredSheetState();
}

class _OnColouredSheetState extends State<OnColouredSheet> {
  final ValueNotifier<bool> _loading = ValueNotifier(false);

  void _conditionalFunction() async {
    if (widget.function == null) {
      widget.fromSnackBar ? Routing().removeSnackBar() : Navigator.pop<bool>(context, true);
    } else {
      try {
        _loading.value = true;
        await widget.function!();
        _loading.value = false;
      } catch (_) {
      } finally {
        if (mounted) {
          widget.fromSnackBar ? Routing().removeSnackBar() : Navigator.pop<bool>(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Row(
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
                  iconData: widget.iconSvg ?? "${AssetPath.vectorPath}valid-invert.svg",
                  defaultColor: false,
                  height: widget.sizeIcon,
                  width: widget.sizeIcon,
                  color: widget.iconColor,
                ),
                eightPx,
                SizedBox(
                  width: MediaQuery.of(context).size.width - (16 + 8 + 14 + 60),
                  child: CustomTextWidget(
                    maxLines: widget.maxLines,
                    textOverflow: widget.textOverflow,
                    textToDisplay: widget.caption,
                    textAlign: TextAlign.left,
                    textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppeLightButtonText),
                  ),
                )
              ],
            ),
            widget.subCaption != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - (16 + 8 + 14 + 60),
                      child: CustomTextWidget(
                        maxLines: widget.maxLines,
                        textToDisplay: widget.subCaption!,
                        textOverflow: TextOverflow.visible,
                        textAlign: TextAlign.left,
                        textStyle: Theme.of(context).textTheme.caption!.copyWith(color: kHyppeLightButtonText),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        widget.subCaption != null
            ? const SizedBox.shrink()
            : SizedBox(
                width: 50,
                height: 50,
                child: CustomTextButton(
                  onPressed: () => _conditionalFunction(),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _loading,
                    builder: (_, value, __) {
                      if (value) {
                        return const SizedBox(height: 40, width: 40, child: CustomLoading());
                      }

                      return CustomTextWidget(
                        maxLines: 1,
                        textToDisplay: 'Ok',
                        textAlign: TextAlign.right,
                        textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: kHyppeLightButtonText),
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }
}
