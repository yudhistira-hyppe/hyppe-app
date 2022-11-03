import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';

class HintPhoneNumber extends StatelessWidget {
  const HintPhoneNumber({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextWidget(
      textToDisplay: 'Pastikan nomor anda sudah benar',
      textStyle: Theme.of(context).textTheme.caption?.copyWith(
            color: Theme.of(context).colorScheme.secondaryVariant,
          ),
    );
  }
}
