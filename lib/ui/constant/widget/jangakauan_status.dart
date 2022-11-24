import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class JangkaunStatus extends StatelessWidget {
  final int jangkauan;
  const JangkaunStatus({Key? key, this.jangkauan = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: kHyppeLightInactive1,
        ),
        width: SizeConfig.screenWidth,
        child: Row(
          children: [
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}reach-fill.svg"),
            sixPx,
            RichText(
                text: TextSpan(text: "${System().formatterNumber(jangkauan)} ", style: Theme.of(context).primaryTextTheme.subtitle2?.copyWith(fontWeight: FontWeight.w700), children: [
              TextSpan(
                text: "${language.reach}",
                style: Theme.of(context).textTheme.subtitle2?.copyWith(),
              ),
            ])),
          ],
        ),
      ),
    );
  }
}
