import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class TextElement extends StatelessWidget {
  final String caption;
  const TextElement({Key? key, required this.caption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: CustomTextWidget(
        textToDisplay: caption,
        textOverflow: TextOverflow.visible,
        textStyle: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
