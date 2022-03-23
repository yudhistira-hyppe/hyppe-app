import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentSlider extends StatelessWidget {
  final int? length;
  const CommentSlider({Key? key, this.length}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
      child: Column(
        children: [
          const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
          SizedBox(height: 16 * SizeConfig.scaleDiagonal),
          CustomRichTextWidget(
            textSpan: TextSpan(
              text: context.read<TranslateNotifierV2>().translate.comment,
              style: Theme.of(context).textTheme.headline6,
              children: [
                TextSpan(
                  text: " (${length ?? "0"})",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 14),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
