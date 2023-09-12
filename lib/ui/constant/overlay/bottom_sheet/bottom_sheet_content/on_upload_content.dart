import 'dart:async';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/notifier_v2.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/upload/make_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../app.dart';

class OnUploadContentBottomSheet extends StatefulWidget {
  final bool isStory;
  final bool isPict;
  final bool isDiary;
  final bool isVid;
  const OnUploadContentBottomSheet({
    super.key,
    this.isDiary = true,
    this.isPict = true,
    this.isStory = true,
    this.isVid = true,
  });

  @override
  State<OnUploadContentBottomSheet> createState() => _OnUploadContentBottomSheetState();
}

class _OnUploadContentBottomSheetState extends State<OnUploadContentBottomSheet> {
  GlobalKey keybutton = GlobalKey();
  String newUser = '';

  @override
  void initState() {
    super.initState();
    newUser = SharedPreference().readStorage(SpKeys.newUser) ?? 'FALSE';
    if (newUser == "TRUE") {
      WidgetsBinding.instance.addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([keybutton]));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final tn = context.read<TranslateNotifierV2>().translate;
    return Consumer<MakeContentNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          if (newUser == "TRUE") {
            return false;
          } else {
            return true;
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                  sixteenPx,
                  CustomTextWidget(
                    textToDisplay: notifier.language.postTo ?? '',
                    textStyle: Theme.of(context).textTheme.headline6,
                  ),

                  // Expanded(
                  //   flex: 2,
                  //   child: Padding(
                  //     padding: EdgeInsets.all(8 * SizeConfig.scaleDiagonal),
                  //     child: Column(
                  //       children: [
                  //         const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
                  //         SizedBox(height: 16 * SizeConfig.scaleDiagonal),
                  //         CustomTextWidget(
                  //           textToDisplay: notifier.language.postTo ?? '',
                  //           textStyle: Theme.of(context).textTheme.headline6,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Showcase(
                    key: keybutton,
                    tooltipBackgroundColor: kHyppeTextLightPrimary,
                    overlayOpacity: 0,
                    targetPadding: const EdgeInsets.only(bottom: -40),
                    tooltipPosition: TooltipPosition.top,
                    title: tn.comeoncreatecontentnow,
                    titleTextStyle: TextStyle(fontSize: 12, color: kHyppeNotConnect),
                    titlePadding: EdgeInsets.all(6),
                    description: tn.tutorLanding6,
                    descTextStyle: TextStyle(fontSize: 10, color: kHyppeNotConnect),
                    descriptionPadding: EdgeInsets.all(6),
                    textColor: Colors.white,
                    targetShapeBorder: const CircleBorder(),
                    disableDefaultTargetGestures: true,
                    descWidget: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "6/6",
                            style: TextStyle(color: kHyppeBurem, fontSize: 10),
                          ),
                          GestureDetector(
                              onTap: () async {
                                Routing().moveBack();
                                SharedPreference().writeStorage(SpKeys.newUser, "FALSE");
                                // ShowCaseWidget.of(context).next();
                                context.read<MainNotifier>().isloading = true;

                                unawaited(
                                  Navigator.of(context, rootNavigator: true).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => WillPopScope(
                                        onWillPop: () async => false,
                                        child: Scaffold(
                                          backgroundColor: Colors.transparent,
                                          body: const Center(
                                            child: CircularProgressIndicator.adaptive(),
                                          ),
                                        ),
                                      ),
                                      transitionDuration: Duration.zero,
                                      barrierDismissible: false,
                                      barrierColor: Colors.black45,
                                      opaque: false,
                                    ),
                                  ),
                                );
                                await Future.delayed(const Duration(seconds: 1));
                                // context.read<HomeNotifier>().tabIndex = 0;

                                Routing().moveBack();
                                // Routing().moveReplacement(Routes.lobby);

                                // Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby);
                              },
                              child: Text(
                                tn.understand ?? '',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        widget.isStory
                            ? Column(
                                children: [
                                  ListTile(
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    onTap: () async {
                                      if (newUser == "FALSE") {
                                        // notifier.thumbnailLocalMedia();
                                        context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                        notifier.featureType = FeatureType.story;
                                        notifier.selectedDuration = 15;
                                        final tempIsHome = isHomeScreen;
                                        if (tempIsHome) {
                                          isHomeScreen = false;
                                        }
                                        await Routing().moveAndPop(Routes.makeContent);
                                        if (tempIsHome) {
                                          isHomeScreen = true;
                                        }
                                      }
                                    },
                                    dense: true,
                                    title: CustomTextWidget(
                                      textToDisplay: "HyppeStory".toLowerCase(),
                                      textAlign: TextAlign.start,
                                      textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                    subtitle: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: CustomTextWidget(
                                        textToDisplay: notifier.language.shareYourMoment ?? '',
                                        textAlign: TextAlign.start,
                                        textStyle: const TextStyle(fontSize: 16, color: Color(0xffaaaaaa)),
                                      ),
                                    ),
                                    leading: CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}story.svg",
                                      height: 27 * SizeConfig.scaleDiagonal,
                                      width: 27 * SizeConfig.scaleDiagonal,
                                      defaultColor: false,
                                    ),
                                    minLeadingWidth: 20,
                                  ),
                                  Divider(thickness: 1, color: Theme.of(context).dividerColor),
                                ],
                              )
                            : Container(),
                        widget.isVid
                            ? Column(
                                children: [
                                  ListTile(
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    onTap: () {
                                      if (newUser == "FALSE") {
                                        context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                        // notifier.thumbnailLocalMedia();
                                        notifier.featureType = FeatureType.vid;
                                        notifier.isVideo = true;
                                        notifier.selectedDuration = 15;
                                        final tempIsHome = isHomeScreen;
                                        if (tempIsHome) {
                                          isHomeScreen = false;
                                        }
                                        Routing().moveAndPop(Routes.makeContent);
                                        if (tempIsHome) {
                                          isHomeScreen = true;
                                        }
                                      }
                                    },
                                    dense: true,
                                    title: CustomTextWidget(
                                      textToDisplay: "HyppeVid".toLowerCase(),
                                      textAlign: TextAlign.start,
                                      textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                    subtitle: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: CustomTextWidget(
                                        textToDisplay: notifier.language.shareWithUsYourCreatifity ?? '',
                                        textAlign: TextAlign.start,
                                        textStyle: const TextStyle(fontSize: 16, color: Color(0xffaaaaaa)),
                                      ),
                                    ),
                                    leading: CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}vid.svg",
                                      height: 27 * SizeConfig.scaleDiagonal,
                                      width: 27 * SizeConfig.scaleDiagonal,
                                      defaultColor: false,
                                    ),
                                    minLeadingWidth: 20,
                                  ),
                                  Divider(thickness: 1, color: Theme.of(context).dividerColor),
                                ],
                              )
                            : Container(),
                        widget.isDiary
                            ? Column(
                                children: [
                                  ListTile(
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    onTap: () {
                                      if (newUser == "FALSE") {
                                        context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                        // notifier.thumbnailLocalMedia();
                                        notifier.featureType = FeatureType.diary;
                                        notifier.isVideo = true;
                                        notifier.selectedDuration = 15;
                                        final tempIsHome = isHomeScreen;
                                        if (tempIsHome) {
                                          isHomeScreen = false;
                                        }
                                        Routing().moveAndPop(Routes.makeContent);
                                        if (tempIsHome) {
                                          isHomeScreen = true;
                                        }
                                      }
                                    },
                                    dense: true,
                                    title: CustomTextWidget(
                                      textToDisplay: "HyppeDiary".toLowerCase(),
                                      textAlign: TextAlign.start,
                                      textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                    subtitle: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: CustomTextWidget(
                                        textToDisplay: notifier.language.howAreYouToday ?? '',
                                        textAlign: TextAlign.start,
                                        textStyle: const TextStyle(fontSize: 16, color: Color(0xffaaaaaa)),
                                      ),
                                    ),
                                    leading: CustomIconWidget(
                                      iconData: "${AssetPath.vectorPath}diary.svg",
                                      height: 27 * SizeConfig.scaleDiagonal,
                                      width: 27 * SizeConfig.scaleDiagonal,
                                      defaultColor: false,
                                    ),
                                    minLeadingWidth: 20,
                                  ),
                                  Divider(thickness: 1, color: Theme.of(context).dividerColor),
                                ],
                              )
                            : Container(),
                        widget.isPict
                            ? ListTile(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onTap: () {
                                  if (newUser == "FALSE") {
                                    context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                                    // notifier.thumbnailLocalMedia();
                                    notifier.featureType = FeatureType.pic;
                                    notifier.isVideo = false;
                                    notifier.selectedDuration = 15;
                                    final tempIsHome = isHomeScreen;
                                    if (tempIsHome) {
                                      isHomeScreen = false;
                                    }
                                    Routing().moveAndPop(Routes.makeContent);
                                    if (tempIsHome) {
                                      isHomeScreen = true;
                                    }
                                    // Future.delayed(const Duration(seconds: 1), (){
                                    //   Routing().moveAndPop(Routes.makeContent);
                                    //   if(tempIsHome){
                                    //     isHomeScreen = true;
                                    //   }
                                    // });
                                  }
                                },
                                dense: true,
                                minLeadingWidth: 20,
                                title: CustomTextWidget(
                                  textToDisplay: "HyppePic".toLowerCase(),
                                  textAlign: TextAlign.start,
                                  textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                subtitle: Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: CustomTextWidget(
                                    textToDisplay: notifier.language.captureYourMoment ?? '',
                                    textAlign: TextAlign.start,
                                    textStyle: const TextStyle(fontSize: 16, color: Color(0xffaaaaaa)),
                                  ),
                                ),
                                leading: CustomIconWidget(
                                  iconData: "${AssetPath.vectorPath}pic.svg",
                                  height: 27 * SizeConfig.scaleDiagonal,
                                  width: 27 * SizeConfig.scaleDiagonal,
                                  defaultColor: false,
                                ),
                              )
                            : Container(),
                        thirtyTwoPx,
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
