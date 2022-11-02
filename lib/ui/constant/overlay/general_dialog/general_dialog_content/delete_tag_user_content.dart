import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/general_mixin/general_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteTagUserContentDialog extends StatefulWidget {
  final String contentTitle;
  final String? postId;
  final Function function;
  const DeleteTagUserContentDialog({Key? key, required this.contentTitle, required this.function, this.postId}) : super(key: key);

  @override
  _DeleteTagUserContentDialogState createState() => _DeleteTagUserContentDialogState();
}

class _DeleteTagUserContentDialogState extends State<DeleteTagUserContentDialog> with GeneralMixin {
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
            textToDisplay: '${_language.removeMeFromPost} ${widget.contentTitle}',
            textStyle: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w600),
          ),
          CustomTextWidget(
            maxLines: 3,
            textOverflow: TextOverflow.visible,
            textToDisplay: _language.afterthatThisTagWillBePermanentlyRemoved ?? '',
            textStyle: theme.textTheme.bodyText1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isLoading)
                // GestureDetector(
                //   onTap: () {
                //     deleteMyTag(context, widget.postId, 'hyppeVid');
                //   },
                //   child: Center(
                //     child: Container(
                //       width: 120,
                //       height: 42,
                //       color: Colors.red,
                //       child: Text(_language.delete),
                //     ),
                //   ),
                // )
                _buildButton(
                  caption: _language.delete ?? 'delete',
                  color: Colors.transparent,
                  function: () {
                    deleteMyTag(context, widget.postId, 'hyppeVid');
                  },
                  // function: () => widget.function(),
                  theme: theme,
                )
              else
                const CustomLoading(),
              _buildButton(
                caption: _language.cancel ?? 'cancel',
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
      child: CustomTextWidget(textToDisplay: caption, textStyle: theme.textTheme.button?.copyWith(color: textColor)),
      width: 120,
      height: 42,
      function: () {
        try {
          setState(() => _isLoading = true);
          function();
          setState(() => _isLoading = false);
        } catch (_) {
          setState(() => _isLoading = false);
        }
      },
      buttonStyle: theme.elevatedButtonTheme.style?.copyWith(
        backgroundColor: MaterialStateProperty.all(color),
      ),
    );
  }
}
