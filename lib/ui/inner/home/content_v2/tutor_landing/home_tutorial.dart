import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/content_v2/tutor_landing/screen.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/main/widget/shimmer_main.dart';
import 'package:hyppe/ui/inner/main/widget/notification_circle.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeTutorScreen extends StatefulWidget {
  const HomeTutorScreen({Key? key}) : super(key: key);

  @override
  State<HomeTutorScreen> createState() => _HomeTutorScreenState();
}

class _HomeTutorScreenState extends State<HomeTutorScreen> with AfterFirstLayoutMixin {
  GlobalKey keyPostButton = GlobalKey();

  @override
  void afterFirstLayout(BuildContext context) {

  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MainScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<MainNotifier>(
      builder: (consumerContext, notifier, __) {
        if (notifier.isloading) {
          Future.delayed(const Duration(milliseconds: 500), () {
            notifier.isloading = false;
          });
        }
        return notifier.isloading
            ? const ShimmerMain()
            : ShowCaseWidget(
                onStart: (index, key) {
                  print('onStart: $index, $key');
                },
                onComplete: (index, key) {
                  print('onComplete: $index, $key');
                },
                blurValue: 0,
                disableBarrierInteraction: true,
                disableMovingAnimation: true,
                builder: Builder(
                  builder: (context) {
                    return Scaffold(
                      backgroundColor: _themes.backgroundColor,
                      body: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: TutorLandingScreen(canShowAds: false, keyButton: keyPostButton),
                      ),
                      floatingActionButton: Visibility(
                        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
                        child: SizedBox(
                          child: FloatingActionButton(
                            onPressed: () {
                              tapMenu(2, notifier, consumerContext);
                            },
                            // shape: RoundedRectangleBorder(),
                            // elevation: 4.0,
                            backgroundColor: Colors.white,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: kHyppePrimary,
                              ),
                              child: CustomIconWidget(
                                defaultColor: false,
                                color: Colors.white,
                                // color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                                iconData: '${AssetPath.vectorPath}logo-purple.svg',
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                      bottomNavigationBar: Showcase(
                        key: keyPostButton,
                        tooltipBackgroundColor: kHyppeTextLightPrimary,
                        overlayOpacity: 0,
                        tooltipPosition: TooltipPosition.top,
                        title: "Upload",
                        titleTextStyle: const TextStyle(fontSize: 12, color: kHyppeNotConnect),
                        titlePadding: const EdgeInsets.all(6),
                        descTextStyle: const TextStyle(fontSize: 10, color: kHyppeNotConnect),
                        descriptionPadding: const EdgeInsets.all(6),
                        description: tn.translate.tutorLanding5,
                        // tooltipBackgroundColor: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        targetShapeBorder: const CircleBorder(),
                        disableDefaultTargetGestures: true,
                        descWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "5/6",
                                style: TextStyle(color: kHyppeBurem, fontSize: 10),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    ShowCaseWidget.of(context).next();
                                    notifier.onShowPostContent(consumerContext);
                                  },
                                  child: Text(
                                    tn.translate.next ?? '',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ),
                        child: BottomAppBar(
                          color: kHyppeLightSurface,
                          height: Platform.isIOS ? 88 : 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: IconButton(
                                  icon: CustomIconWidget(
                                    defaultColor: false,
                                    color: notifier.pageIndex == 0 ? kHyppeTextLightPrimary : _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                                    iconData: notifier.pageIndex == 0 ? '${AssetPath.vectorPath}home-active.svg' : '${AssetPath.vectorPath}home.svg',
                                  ),
                                  onPressed: () async {
                                    print(notifier.pageIndex);
                                    // if (notifier.pageIndex == 0) {

                                    // } else {
                                    tapMenu(0, notifier, consumerContext);
                                    if (notifier.scrollController.hasClients) {
                                      if (globalTultipShow) {
                                        return;
                                      }
                                      homeClick = true;
                                      notifier.scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
                                      // Routing.navigatorKey.currentState?.overlay?.context
                                      //     .read<MainNotifier>()
                                      //     .globalKey
                                      //     .currentState
                                      //     ?.innerController
                                      //     .animateTo(0, duration: const Duration(seconds: 1), curve: Curves.ease)
                                      //     .then((value) {
                                      //   notifier.scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.elasticOut);
                                      // });
                                    }
                                    Future.delayed(const Duration(milliseconds: 1000), () {});

                                    // }
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: CustomIconWidget(
                                    defaultColor: false,
                                    color: notifier.pageIndex == 1 ? kHyppeTextLightPrimary : _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                                    iconData: notifier.pageIndex == 1 ? '${AssetPath.vectorPath}search-active.svg' : '${AssetPath.vectorPath}search-nav.svg',
                                  ),
                                  onPressed: () {
                                    print("ke menu search");
                                    tapMenu(1, notifier, consumerContext);
                                  },
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // tapMenu(2, notifier, consumerContext);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    // child: CustomIconWidget(
                                    //   defaultColor: false,
                                    //   iconData: '${AssetPath.vectorPath}hyppe-button.svg',
                                    // ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: Stack(children: [
                                    CustomIconWidget(
                                      defaultColor: false,
                                      color: notifier.pageIndex == 3 ? kHyppeTextLightPrimary : _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                                      iconData: notifier.pageIndex == 3 ? '${AssetPath.vectorPath}notification-active.svg' : '${AssetPath.vectorPath}notification.svg',
                                    ),
                                    const NotificationCircle()
                                  ]),
                                  onPressed: () {
                                    tapMenu(3, notifier, consumerContext);
                                    context.read<MainNotifier>().receivedReaction = false;
                                  },
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  icon: const SizedBox(width: 32, child: Profile()),
                                  onPressed: () {
                                    print(notifier.pageIndex);
                                    tapMenu(4, notifier, consumerContext);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
      },
    );
  }

  void tapMenu(int index, MainNotifier notifier, consumerContext) async {
    String newUser = SharedPreference().readStorage(SpKeys.newUser) ?? '';
    if (newUser == "TRUE" || globalTultipShow) {
      return;
    }
    if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
    if (index != 2) {
      setState(() {
        'pageIndex now: $index'.logger();
        notifier.pageIndex = index;
      });
    } else {
      await notifier.onShowPostContent(consumerContext);
    }
  }
}
