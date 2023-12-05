import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../core/models/collection/localization_v2/localization_model.dart';

class SearchNoResult extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final LocalizationModelV2 locale;
  final String keyword;
  const SearchNoResult(
      {Key? key, this.margin, required this.locale, required this.keyword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SearchNoResult');
    return Container(
      margin: margin,
      child: CustomTextWidget(
        textToDisplay: keyword.isEmpty ? '${locale.noData}' :'${locale.noResultsFor} "$keyword"',
        textStyle: context.getTextTheme().bodyText1,
      ),
    );
  }
}
