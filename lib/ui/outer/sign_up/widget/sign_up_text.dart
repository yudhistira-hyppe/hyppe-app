import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class SignUpText extends StatelessWidget {
  final String title;
  final String description;
  final double? paddingDescription;
  const SignUpText({Key? key, required this.title, required this.description, this.paddingDescription}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CustomTextWidget(
        textToDisplay: title,
        textStyle: Theme.of(context).textTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
      ),
      eightPx,
      Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingDescription ?? 0),
        child: CustomTextWidget(
          maxLines: null,
          textToDisplay: description,
          textOverflow: TextOverflow.visible,
          textStyle: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    ],
  );
}
