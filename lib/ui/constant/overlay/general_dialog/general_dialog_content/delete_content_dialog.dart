import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteContentDialog extends StatefulWidget {
  final String contentTitle;
  final Function function;
  const DeleteContentDialog({
    Key? key,
    required this.contentTitle,
    required this.function,
  }) : super(key: key);

  @override
  _DeleteContentDialogState createState() => _DeleteContentDialogState();
}

class _DeleteContentDialogState extends State<DeleteContentDialog> {
  final _routing = Routing();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final _language = context.watch<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(8.0)),
      height: 183,
      width: size.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CustomTextWidget(
            textToDisplay: '${_language.deleteThis} ${widget.contentTitle}',
            textStyle: theme.textTheme.subtitle1!.copyWith(fontWeight: FontWeight.w600),
          ),
          CustomTextWidget(
            maxLines: 2,
            textOverflow: TextOverflow.visible,
            textToDisplay: '${_language.afterThatThis} ${widget.contentTitle} ${_language.willBePermanentlyDeleted}',
            textStyle: theme.textTheme.bodyText1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isLoading)
                _buildButton(
                  caption: _language.delete!,
                  color: Colors.transparent,
                  function: () => widget.function(),
                  theme: theme,
                )
              else
                const CustomLoading(),
              _buildButton(
                caption: _language.dontDelete!,
                color: theme.colorScheme.primaryVariant,
                textColor: kHyppeLightButtonText,
                function: () => _routing.moveBack(),
                theme: theme,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildButton({required ThemeData theme, required String caption, required Function function, required Color color, Color? textColor}) {
    return CustomElevatedButton(
      child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button!.copyWith(color: textColor)),
      width: 120,
      height: 42,
      function: () async {
        try {
          setState(() => _isLoading = true);
          await function();
          setState(() => _isLoading = false);
        } catch (_) {
          setState(() => _isLoading = false);
        }
      },
      buttonStyle: theme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );
  }
}
