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
  final bool isDiary;
  const JangkaunStatus({Key? key, this.jangkauan = 0, this.isDiary = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = context.read<TranslateNotifierV2>().translate;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        margin: isDiary
            ? const EdgeInsets.all(0)
            : const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDiary ? Colors.black.withOpacity(0.3) : kHyppeLightInactive1,
        ),
        width: SizeConfig.screenWidth,
        child: Row(
          children: [
            CustomIconWidget(
              iconData: "${AssetPath.vectorPath}reach-fill.svg",
              defaultColor: false,
              color: isDiary ? Colors.white : kHyppeLightIcon,
            ),
            sixPx,
            RichText(
                text: TextSpan(
                    text: "${System().formatterNumber(jangkauan)} ",
                    style: isDiary
                        ? Theme.of(context)
                            .primaryTextTheme
                            .titleSmall
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)
                        : Theme.of(context)
                            .primaryTextTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                    children: [
                  TextSpan(
                    text: "${language.reach}",
                    style: isDiary
                        ? Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.white)
                        : Theme.of(context).textTheme.titleSmall?.copyWith(),
                  ),
                ])),
          ],
        ),
      ),
    );
  }
}
