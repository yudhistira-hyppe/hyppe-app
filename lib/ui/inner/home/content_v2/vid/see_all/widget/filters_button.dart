import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

class FiltersButton extends StatelessWidget {
  const FiltersButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 81,
      height: 30,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      alignment: Alignment.center,
      child: CustomTextWidget(
        textToDisplay: "Filters",
        textStyle: theme.textTheme.button,
      ),
    );
  }
}
