import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:provider/provider.dart';

class ShareBlock extends StatefulWidget {
  const ShareBlock({Key? key}) : super(key: key);

  @override
  State<ShareBlock> createState() => _ShareBlockState();
}

class _ShareBlockState extends State<ShareBlock> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralNotifier>(
        builder: (_, notifier, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: notifier.language.shareStatus!,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kHyppeTextLightPrimary,
                      ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: kHyppeLightSurface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        textToDisplay: notifier.language.hasUsed!,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: kHyppeLightSecondary,
                                ),
                      ),
                      CustomTextWidget(
                        textToDisplay: "184",
                        textStyle: Theme.of(context).textTheme.button?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.primaryVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                CustomTextWidget(
                  textToDisplay: notifier.language.linkYourReferral!,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: kHyppeTextLightPrimary,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  decoration: BoxDecoration(
                    color: kHyppeLightSurface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTextWidget(
                          textToDisplay: notifier.referralLink,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kHyppeLightSecondary,
                                  ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => System().shareText(
                              dynamicLink: notifier.referralLink,
                              context: context),
                          child: Container(
                            width: 93,
                            height: 32,
                            decoration: BoxDecoration(
                                color: kHyppePrimary,
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomTextWidget(
                                  textToDisplay: notifier.language.share!,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .button
                                      ?.copyWith(color: kHyppeLightButtonText),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
}
