import 'package:hyppe/ui/constant/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/outer/sign_up/contents/pin/notifier.dart';
import 'package:provider/provider.dart';

class RectangleInput extends StatelessWidget {
  final TextEditingController input;
  final Function(String) onChanged;
  final ValueChanged<RawKeyEvent>? onKeyEvent;
  final FocusNode focusNode;
  const RectangleInput({
    Key? key,
    required this.input,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpPinNotifier>(
      builder: (_, notifier, __) => Flexible(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: onKeyEvent,
          child: CustomTextFormField(
            inputAreaWidth: 40,
            inputAreaHeight: 40,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.number,
            textEditingController: input,
            focusNode: focusNode,
            onChanged: onChanged,
            maxLength: 1,
            style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.bold),
            inputDecoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 12),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: notifier.inCorrectCode ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primaryVariant,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: notifier.inCorrectCode
                        ? Theme.of(context).colorScheme.error
                        : input.text.isNotEmpty
                            ? Theme.of(context).colorScheme.primaryVariant
                            : Theme.of(context).primaryTextTheme.button?.color ?? Colors.white,
                    width: 1.0),
              ),
              counterText: "",
            ),
          ),
        ),
      ),
    );
  }
}
