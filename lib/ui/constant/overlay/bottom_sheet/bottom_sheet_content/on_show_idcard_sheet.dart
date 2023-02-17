import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnShowInfoIdCardBottomSheet extends StatelessWidget {
  const OnShowInfoIdCardBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = context.read<TranslateNotifierV2>().translate;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal, horizontal: 16 * SizeConfig.scaleDiagonal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
          CustomTextWidget(
            textOverflow: TextOverflow.visible,
            textStyle: Theme.of(context).textTheme.bodyMedium,
            textToDisplay: translate.pleaseMakeSuretheResidenceNumberMatchestheEKTP ?? '',
          ),
        ],
      ),
    );
  }
}
