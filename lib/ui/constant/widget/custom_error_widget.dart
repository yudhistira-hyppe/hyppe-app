import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomErrorWidget extends StatelessWidget {
  final bool isVertical;
  final double? iconSize;
  final Function? function;
  final ErrorType? errorType;
  final EdgeInsetsGeometry padding;

  const CustomErrorWidget(
      {Key? key,
      this.function,
      this.iconSize,
      required this.errorType,
      this.isVertical = true,
      this.padding = const EdgeInsets.symmetric(horizontal: 16)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<ErrorService, TranslateNotifierV2>(
      builder: (_, value, value2, __) {
        return isVertical
            ? GestureDetector(
                onTap: () async => await value.refresh(this, function),
                child: Padding(
                  padding: padding,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      Center(
                        child: Flex(
                          direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconData:
                                  "${AssetPath.vectorPath}unexpected-error.svg",
                              defaultColor: false,
                              height: iconSize,
                              width: iconSize,
                            ),
                            eightPx,
                            value.refreshing(this)
                                ? UnconstrainedBox(
                                    child: CircularProgressIndicator(
                                        color: theme.colorScheme.primary,
                                        strokeWidth: 2.0))
                                : CustomTextWidget(
                                    textToDisplay:
                                        "${value2.translate.sorryUnexpectedError}",
                                    textStyle: theme.textTheme.titleMedium),
                            if (errorType != ErrorType.peopleStory) fourPx,
                            if (errorType != ErrorType.peopleStory)
                              CustomTextWidget(
                                  textToDisplay:
                                      "${value2.translate.weAreWorkingOnFixingTheProblemBeBackSoon}",
                                  textStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                          color: theme.colorScheme.secondary))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}unexpected-error.svg",
                      defaultColor: false,
                      height: iconSize,
                      width: iconSize,
                    ),
                    eightPx,
                    value.refreshing(this)
                        ? UnconstrainedBox(
                            child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                                strokeWidth: 2.0))
                        : CustomTextWidget(
                            textToDisplay:
                                "${value2.translate.sorryUnexpectedError}",
                            textStyle: theme.textTheme.titleMedium),
                    if (errorType != ErrorType.peopleStory) fourPx,
                    if (errorType != ErrorType.peopleStory)
                      CustomTextWidget(
                          textToDisplay:
                              "${value2.translate.weAreWorkingOnFixingTheProblemBeBackSoon}",
                          textStyle: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.secondary))
                  ],
                ),
              );
      },
    );
  }
}
