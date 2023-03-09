import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import '../../../../core/models/collection/localization_v2/localization_model.dart';

class SearchNoResultImage extends StatelessWidget {
  LocalizationModelV2 locale;
  String keyword;
  SearchNoResultImage({Key? key, required this.locale, required this.keyword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 700,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomIconWidget(
            iconData: '${AssetPath.vectorPath}icon_no_result.svg',
            width: 160,
            height: 160,
            defaultColor: false,
          ),
          tenPx,
          CustomTextWidget(
            textAlign: TextAlign.center,
            maxLines: 1,
            textToDisplay: '${locale.noResultsFor} "$keyword"',
            textStyle: context.getTextTheme().bodyText1?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.getColorScheme().onBackground),
          ),
          eightPx,
          CustomTextWidget(
            textAlign: TextAlign.center,
            maxLines: 2,
            textToDisplay: '${locale.messageNoResult}',
            textStyle: context.getTextTheme().bodyText1,
          ),
        ],
      ),
    );
  }
}
