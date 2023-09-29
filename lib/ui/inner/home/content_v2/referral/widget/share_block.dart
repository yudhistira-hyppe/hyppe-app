import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/referral_list_user.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../../ux/routing.dart';

class ShareBlock extends StatefulWidget {
  final GlobalKey? globalKey;
  final TooltipPosition? positionTooltip;
  final String? descriptionCas;
  final double? positionYplus;
  final int? indexTutor;
  const ShareBlock({Key? key, this.globalKey, this.positionTooltip, this.descriptionCas, this.positionYplus, this.indexTutor}) : super(key: key);

  @override
  State<ShareBlock> createState() => _ShareBlockState();
}

class _ShareBlockState extends State<ShareBlock> {
  MainNotifier? mn;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ShareBlock');
    super.initState();
    mn = Provider.of<MainNotifier>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralNotifier>(
        builder: (_, notifier, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                  textToDisplay: notifier.language.shareStatus ?? '',
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
                      GestureDetector(
                        onTap: () {
                          Routing().move(Routes.listReferral, argument: ReferralListUserArgument(modelReferral: notifier.modelReferral));
                        },
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.hasUsed ?? '',
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kHyppeLightSecondary,
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Routing().move(Routes.listReferral, argument: ReferralListUserArgument(modelReferral: notifier.modelReferral));
                        },
                        child: CustomTextWidget(
                          textToDisplay: notifier.modelReferral?.data != null ? '${notifier.modelReferral?.data}' : '0',
                          textStyle: Theme.of(context).textTheme.button?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomTextWidget(
                  textToDisplay: notifier.language.linkYourReferral ?? '',
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
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kHyppeLightSecondary,
                              ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Showcase(
                          key: widget.globalKey ?? GlobalKey(),
                          tooltipBackgroundColor: kHyppeTextLightPrimary,
                          overlayOpacity: 0,
                          targetPadding: const EdgeInsets.all(0),
                          tooltipPosition: widget.positionTooltip,
                          description: (mn?.tutorialData.isEmpty ?? [].isEmpty)
                              ? ''
                              : notifier.language.localeDatetime == 'id'
                                  ? mn?.tutorialData[widget.indexTutor ?? 0].textID ?? ''
                                  : mn?.tutorialData[widget.indexTutor ?? 0].textEn ?? '',
                          descTextStyle: TextStyle(fontSize: 10, color: kHyppeNotConnect),
                          descriptionPadding: EdgeInsets.all(6),
                          textColor: Colors.white,
                          targetShapeBorder: const CircleBorder(),
                          positionYplus: widget.positionYplus,
                          onToolTipClick: () {
                            context.read<TutorNotifier>().postTutor(context, mn?.tutorialData[widget.indexTutor ?? 0].key ?? '');
                            mn?.tutorialData[widget.indexTutor ?? 0].status = true;
                            ShowCaseWidget.of(context).next();
                          },
                          closeWidget: GestureDetector(
                            onTap: () {
                              context.read<TutorNotifier>().postTutor(context, mn?.tutorialData[widget.indexTutor ?? 0].key ?? '');
                              mn?.tutorialData[widget.indexTutor ?? 0].status = true;
                              ShowCaseWidget.of(context).next();
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CustomIconWidget(
                                iconData: '${AssetPath.vectorPath}close.svg',
                                defaultColor: false,
                                height: 16,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => System().shareText(dynamicLink: notifier.referralLinkText, context: context),
                            child: Container(
                              width: 93,
                              height: 32,
                              decoration: BoxDecoration(color: kHyppePrimary, borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomTextWidget(
                                    textToDisplay: notifier.language.share ?? '',
                                    textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
                                  ),
                                ],
                              ),
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
