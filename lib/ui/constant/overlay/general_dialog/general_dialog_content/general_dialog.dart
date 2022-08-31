import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneralAlertDialog extends StatelessWidget {
  String? titleText;
  String? bodyText;
  int? maxLineTitle;
  int? maxLineBody;
  Function functionPrimary;
  Function? functionSecondary;
  String? titleButtonPrimary;
  String? titleButtonSecondary;
  GeneralAlertDialog(
      {Key? key, this.titleText, this.bodyText, this.maxLineTitle, this.maxLineBody, required this.functionPrimary, this.functionSecondary, this.titleButtonPrimary, this.titleButtonSecondary})
      : super(key: key);
  final _routing = Routing();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final _language = context.watch<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomTextWidget(
            textToDisplay: '$titleText',
            maxLines: maxLineTitle,
            textStyle: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w600),
          ),
          twelvePx,
          CustomTextWidget(
            maxLines: maxLineBody,
            textOverflow: TextOverflow.visible,
            textToDisplay: '$bodyText',
            textStyle: theme.textTheme.bodyText2,
          ),
          twelvePx,
          twelvePx,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              functionSecondary == null
                  ? Container()
                  : Expanded(
                      child: _buildButton(
                        caption: '$titleButtonSecondary',
                        color: Colors.transparent,
                        function: functionSecondary!,
                        // function: () => _routing.moveBack(),
                        theme: theme,
                      ),
                    ),
              Expanded(
                child: _buildButton(
                  caption: '$titleButtonPrimary',
                  textColor: kHyppeLightButtonText,
                  color: theme.colorScheme.primaryVariant,
                  function: functionSecondary!,
                  // function: () => widget.function(),
                  theme: theme,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildButton({required ThemeData theme, required String caption, required Function function, required Color color, Color? textColor}) {
    return CustomTextButton(
      onPressed: function,
      child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button!.copyWith(color: textColor, fontSize: 10)),
      style: theme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );

    return CustomElevatedButton(
      child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button!.copyWith(color: textColor, fontSize: 10)),
      width: 120,
      height: 42,
      function: () {
        try {
          function();
        } catch (_) {}
      },
      buttonStyle: theme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );
  }
}
