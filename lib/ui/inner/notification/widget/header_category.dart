import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class HeaderCategory extends StatelessWidget {
  final String caption;

  const HeaderCategory({Key? key, required this.caption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: CustomTextWidget(textToDisplay: caption, textStyle: Theme.of(context).textTheme.bodyText1),
        ));
  }
}
