import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../core/models/collection/localization_v2/localization_model.dart';

class SearchNoResult extends StatelessWidget {
  EdgeInsetsGeometry? margin;
  LocalizationModelV2 locale;
  String keyword;
  SearchNoResult(
      {Key? key, this.margin, required this.locale, required this.keyword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: CustomTextWidget(
        textToDisplay: '${locale.noResultsFor} "$keyword"',
        textStyle: context.getTextTheme().bodyText1,
      ),
    );
  }
}