import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/widget/qr_block.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/widget/share_block.dart';
import 'package:hyppe/ui/inner/home/content_v2/referral/widget/shimmer_referral.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/notifier.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class Referral extends StatefulWidget {
  const Referral({Key? key}) : super(key: key);

  @override
  State<Referral> createState() => _ReferralState();
}

class _ReferralState extends State<Referral> {
  GlobalKey keyShare = GlobalKey();
  GlobalKey keyCode = GlobalKey();
  MainNotifier? mn;
  int indexKeyShare = 0;
  int indexCode = 0;
  ScrollController controller = ScrollController();
  var myContext;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Referral');
    final notifier = Provider.of<ReferralNotifier>(context, listen: false);
    Future.delayed(Duration.zero, () => notifier.onInitial(context));

    super.initState();
    mn = Provider.of<MainNotifier>(context, listen: false);
    super.initState();
    if (mn?.tutorialData.isNotEmpty ?? [].isEmpty) {
      indexKeyShare = mn?.tutorialData
              .indexWhere((element) => element.key == 'shareRefferal') ??
          0;
      indexCode = mn?.tutorialData
              .indexWhere((element) => element.key == 'codeRefferal') ??
          0;

      if (mn?.tutorialData[indexKeyShare].status == false &&
          mn?.tutorialData[indexCode].status == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(myContext).startShowCase([keyShare, keyCode]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<ReferralNotifier>(
      builder: (_, notifier, __) => ShowCaseWidget(
        onStart: (index, key) {
          print('onStart: $index, $key');
        },
        onComplete: (index, key) {
          print('onComplete: $index, $key');
        },
        blurValue: 0,
        disableBarrierInteraction: true,
        disableMovingAnimation: true,
        builder: Builder(builder: (context) {
          myContext = context;
          return Scaffold(
            appBar: AppBar(
              leadingWidth:
                  50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
              leading: CustomIconButtonWidget(
                defaultColor: true,
                iconData: "${AssetPath.vectorPath}back-arrow.svg",
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Routing().moveBack();
                  });
                },
              ),
              titleSpacing: 0,
              title: CustomTextWidget(
                textToDisplay: notifier.language.referralID ?? '',
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 18),
              ),
              centerTitle: false,
            ),
            body: CustomScrollView(
              controller: controller,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: notifier.loading
                      ? const ShimmerReferral()
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShareBlock(
                                globalKey: keyShare,
                                indexTutor: indexKeyShare,
                                positionTooltip: TooltipPosition.top,
                                positionYplus: 25,
                              ),
                              const Spacer(),
                              const QRBlock(),
                              const Spacer(),
                              notifier.modelReferral?.parent == null
                                  ? textInputReff(notifier.language)
                                  : notifier.modelReferral?.parent == null ||
                                          notifier.modelReferral?.parent == ""
                                      ? textInputReff(notifier.language)
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Diundang oleh: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium),
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: kHyppeLightSurface),
                                              child: Text(
                                                '${notifier.modelReferral?.parent}',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                            ),
                                          ],
                                        )

                              // CustomElevatedButton(
                              //   width: 375.0 * SizeConfig.scaleDiagonal,
                              //   height: 44.0 * SizeConfig.scaleDiagonal,
                              //   function: () => null,
                              //   child: CustomTextWidget(
                              //     textToDisplay: notifier.language.downloadQRCode,
                              //     textStyle: Theme.of(context)
                              //         .textTheme
                              //         .button
                              //         ?.copyWith(color: kHyppeLightButtonText),
                              //   ),
                              //   buttonStyle: ButtonStyle(
                              //     foregroundColor: MaterialStateProperty.all(
                              //         Theme.of(context).colorScheme.primary),
                              //     shadowColor: MaterialStateProperty.all(
                              //         Theme.of(context).colorScheme.primary),
                              //     overlayColor: MaterialStateProperty.all(
                              //         Theme.of(context).colorScheme.primary),
                              //     backgroundColor: MaterialStateProperty.all(
                              //         Theme.of(context).colorScheme.primary),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget textInputReff(LocalizationModelV2 lang) {
    return Container();
    // return SizedBox(
    //   height: 30,
    //   child: Showcase(
    //     key: keyCode,
    //     tooltipBackgroundColor: kHyppeTextLightPrimary,
    //     overlayOpacity: 0,
    //     targetPadding: const EdgeInsets.all(0),
    //     tooltipPosition: TooltipPosition.top,
    //     description: (mn?.tutorialData.isEmpty ?? [].isEmpty)
    //         ? ''
    //         : lang.localeDatetime == 'id'
    //             ? mn?.tutorialData[indexCode].textID ?? ''
    //             : mn?.tutorialData[indexCode].textEn ?? '',
    //     descTextStyle: TextStyle(fontSize: 10, color: kHyppeNotConnect),
    //     descriptionPadding: EdgeInsets.all(6),
    //     textColor: Colors.white,
    //     targetShapeBorder: const CircleBorder(),
    //     positionYplus: 20,
    //     onToolTipClick: () {
    //       context.read<TutorNotifier>().postTutor(context, mn?.tutorialData[indexCode].key ?? '');
    //       mn?.tutorialData[indexCode].status = true;
    //       ShowCaseWidget.of(myContext).next();
    //     },
    //     closeWidget: GestureDetector(
    //       onTap: () {
    //         context.read<TutorNotifier>().postTutor(context, mn?.tutorialData[indexCode].key ?? '');
    //         mn?.tutorialData[indexCode].status = true;
    //         ShowCaseWidget.of(myContext).next();
    //       },
    //       child: const Padding(
    //         padding: EdgeInsets.all(8.0),
    //         child: CustomIconWidget(
    //           iconData: '${AssetPath.vectorPath}close.svg',
    //           defaultColor: false,
    //           height: 16,
    //         ),
    //       ),
    //     ),
    //     child: GestureDetector(
    //       onTap: () {
    //         Routing().move(Routes.insertReferral);
    //       },
    //       child: const Text(
    //         'Masukkan Referral',
    //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kHyppePrimary),
    //       ),
    //     ),
    //   ),
    // );
  }
}
