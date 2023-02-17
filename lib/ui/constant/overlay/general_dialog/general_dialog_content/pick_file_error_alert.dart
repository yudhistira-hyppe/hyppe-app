import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';

class PickFileErrorAlertContent extends StatelessWidget {
  final String message;
  const PickFileErrorAlertContent({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: CustomTextWidget(
          textStyle: Theme.of(context).textTheme.bodyText1,
          textToDisplay: message,
          textOverflow: TextOverflow.visible),
      actions: [
        CustomTextButton(
          onPressed: () => Routing().moveBack(),
          child: CustomTextWidget(
            textStyle:
            Theme.of(context).textTheme.button?.apply(color: Theme.of(context).colorScheme.primary),
            textToDisplay: 'Ok',
          ),
        ),
      ],
    );
  }
}
