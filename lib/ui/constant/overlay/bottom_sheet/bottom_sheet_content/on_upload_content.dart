import 'package:flutter_livepush_plugin/live_base.dart';
import 'package:flutter_livepush_plugin/live_push_config.dart';
import 'package:flutter_livepush_plugin/live_push_def.dart';
import 'package:flutter_livepush_plugin/live_pusher.dart';
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
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
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
  final bool isLive;
  const OnUploadContentBottomSheet({
    super.key,
    this.isDiary = true,
    this.isPict = true,
    this.isStory = true,
    this.isVid = true,
    this.isLive = true,
  });

  @override
  State<OnUploadContentBottomSheet> createState() => _OnUploadContentBottomSheetState();
}

class _OnUploadContentBottomSheetState extends State<OnUploadContentBottomSheet> {
  GlobalKey keybutton = GlobalKey();
  String newUser = '';

  late AlivcBase _alivcBase;
  late AlivcLivePusher _alivcLivePusher;
  late AlivcLivePusherConfig _alivcLivePusherConfig;
  bool isCreator = false;

  @override
  void initState() {
    print("OnUploadContentBottomSheet");
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // _initPush();
      setState(() {
        isCreator = context.read<SelfProfileNotifier>().user.profile?.creator ?? false;
      });
      newUser = SharedPreference().readStorage(SpKeys.newUser) ?? 'FALSE';
      if (newUser == "TRUE") {
        WidgetsBinding.instance.addPostFrameCallback((_) => ShowCaseWidget.of(context).startShowCase([keybutton]));
      }
    });
  }

  Future<void> _initPush() async {
    // context.read<StreamerNotifier>().init(context, mounted);
    _alivcBase = AlivcBase.init();
    _alivcBase.registerSDK().then((value) => print(value));
    _alivcBase.setObserver();
    _alivcBase.setOnLicenceCheck((result, reason) {
      print('sad');
      print("======== belum ada lisensi $reason ========");
      if (result != AlivcLiveLicenseCheckResultCode.success) {
        print("======== belum ada lisensi $reason ========");
      }
    });
    _alivcLivePusherConfig = AlivcLivePusherConfig.init();
    _alivcLivePusherConfig.setCameraType(AlivcLivePushCameraType.front);
    _alivcLivePusher = AlivcLivePusher.init();
    _alivcLivePusher.createConfig();
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
          mainAxisSize: MainAxisSize.min,
          children: [
            sixteenPx,
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg"),
            sixteenPx,
            CustomTextWidget(
              textToDisplay: notifier.language.postTo ?? '',
              textStyle: Theme.of(context).textTheme.headline6,
            ),
            Showcase(
              key: keybutton,
              tooltipBackgroundColor: kHyppeTextLightPrimary,
              overlayOpacity: 0,
              targetPadding: const EdgeInsets.only(bottom: -40),
              tooltipPosition: TooltipPosition.top,
              title: tn.comeoncreatecontentnow,
              titleTextStyle: const TextStyle(fontSize: 12, color: kHyppeNotConnect),
              titlePadding: const EdgeInsets.all(6),
              description: tn.tutorLanding6,
              descTextStyle: const TextStyle(fontSize: 10, color: kHyppeNotConnect),
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
                          SharedPreference().writeStorage(SpKeys.newUser, "FALSE");
                          // ShowCaseWidget.of(context).next();
                          context.read<MainNotifier>().isloading = true;
                          // unawaited(
                          //   Navigator.of(context, rootNavigator: true).push(
                          //     PageRouteBuilder(
                          //       pageBuilder: (_, __, ___) => WillPopScope(
                          //         onWillPop: () async => false,
                          //         child: Scaffold(
                          //           backgroundColor: Colors.transparent,
                          //           body: const Center(
                          //             child: CircularProgressIndicator.adaptive(),
                          //           ),
                          //         ),
                          //       ),
                          //       transitionDuration: Duration.zero,
                          //       barrierDismissible: false,
                          //       barrierColor: Colors.black45,
                          //       opaque: false,
                          //     ),
                          //   ),
                          // );
                          // await Future.delayed(const Duration(seconds: 1));
                          // context.read<HomeNotifier>().tabIndex = 0;
                          Routing().moveAndRemoveUntil(Routes.lobby, Routes.root);
                        },
                        child: Text(
                          tn.understand ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ),
              child: Column(
                children: [
                  widget.isStory
                      ? Column(
                          children: [
                            menu(
                                title: "HyppeStory".toLowerCase(),
                                subTitle: notifier.language.shareYourMoment ?? '',
                                icon: "${AssetPath.vectorPath}story.svg",
                                function: () async {
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
                                }),
                            Divider(thickness: 1, color: Theme.of(context).dividerColor),
                          ],
                        )
                      : Container(),
                  widget.isVid
                      ? Column(
                          children: [
                            menu(
                                title: "HyppeVid".toLowerCase(),
                                subTitle: notifier.language.shareWithUsYourCreatifity ?? '',
                                icon: "${AssetPath.vectorPath}vid.svg",
                                function: () async {
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
                                }),
                            Divider(thickness: 1, color: Theme.of(context).dividerColor),
                          ],
                        )
                      : Container(),
                  widget.isDiary
                      ? Column(
                          children: [
                            menu(
                                title: "HyppeDiary".toLowerCase(),
                                subTitle: notifier.language.howAreYouToday ?? '',
                                icon: "${AssetPath.vectorPath}diary.svg",
                                function: () async {
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
                                }),
                            Divider(thickness: 1, color: Theme.of(context).dividerColor),
                          ],
                        )
                      : Container(),
                  widget.isPict
                      ? Column(
                          children: [
                            menu(
                                title: "HyppePic".toLowerCase(),
                                subTitle: notifier.language.captureYourMoment ?? '',
                                icon: "${AssetPath.vectorPath}pic.svg",
                                function: () async {
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
                                    await Routing().moveAndPop(Routes.makeContent);
                                    if (tempIsHome) {
                                      isHomeScreen = true;
                                    }
                                  }
                                }),
                            Divider(thickness: 1, color: Theme.of(context).dividerColor),
                          ],
                        )
                      : Container(),
                  // Text('hahaha ${isCreator}'),
                  widget.isLive
                      ? menu(
                          isCreators: isCreator,
                          title: "Hyppelive".toLowerCase(),
                          subTitle: notifier.language.itstimetoLIVEandinteract ?? '',
                          icon: "${AssetPath.vectorPath}hyppeLive.svg",
                          function: () async {
                            if (newUser == "FALSE") {
                              // context.read<PreviewVidNotifier>().canPlayOpenApps = false; //biar ga play di landingpage
                              // final tempIsHome = isHomeScreen;
                              // if (tempIsHome) {
                              //   isHomeScreen = false;
                              // }
                              if (isCreator) Routing().moveAndPop(Routes.streamer);
                              // if (tempIsHome) {
                              //   isHomeScreen = true;
                              // }
                            }
                          })
                      : Container(),
                  thirtyTwoPx,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget menu({String? title, String? subTitle, String? icon, Function()? function, bool? isCreators}) {
    return ListTile(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      onTap: function,
      dense: true,
      minLeadingWidth: 20,
      title: CustomTextWidget(
        textToDisplay: title ?? '',
        textAlign: TextAlign.start,
        textStyle: Theme.of(context).textTheme.bodyText1?.copyWith(fontSize: 18, fontWeight: FontWeight.w800, color: isCreators != null && !isCreators ? kHyppeBurem : null),
      ),
      subtitle: Container(
        margin: const EdgeInsets.only(top: 5),
        child: CustomTextWidget(
          textToDisplay: "$subTitle",
          textAlign: TextAlign.start,
          textStyle: const TextStyle(fontSize: 16, color: Color(0xffaaaaaa)),
        ),
      ),
      leading: CustomIconWidget(
        iconData: "$icon",
        height: 27 * SizeConfig.scaleDiagonal,
        width: 27 * SizeConfig.scaleDiagonal,
        defaultColor: false,
        color: isCreators != null && !isCreators ? kHyppeBurem : kHyppePrimary,
      ),
    );
  }
}
