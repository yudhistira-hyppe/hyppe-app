import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/log_extension.dart';
import 'package:hyppe/core/services/audio_service.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/main/widget/shimmer_main.dart';
import 'package:hyppe/ui/inner/main/widget/notification_circle.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/arguments/main_argument.dart';
import '../../../core/constants/shared_preference_keys.dart';
import '../../../core/services/shared_preference.dart';
import '../../constant/overlay/bottom_sheet/show_bottom_sheet.dart';

class MainScreen extends StatefulWidget {
  final MainArgument? args;
  const MainScreen({Key? key, this.args}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AfterFirstLayoutMixin {
  late MainNotifier _mainNotifier;
  GlobalKey keyPostButton = GlobalKey();
  bool isPagePict = true;

  @override
  void afterFirstLayout(BuildContext context) {
    _mainNotifier.initMain(context, isInitSocket: true);
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MainScreen');
    _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
    _mainNotifier.globalKey = GlobalKey<NestedScrollViewState>(debugLabel: System().generateNonce());
    _mainNotifier.pageInit(widget.args?.canShowAds ?? true);
    print("=========init main ${_mainNotifier.globalKey}");

    ScrollController(initialScrollOffset: 50.0);

    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
    super.initState();
    _mainNotifier.setPageIndex(widget.args?.page ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    TranslateNotifierV2 tn = context.read<TranslateNotifierV2>();
    return Consumer<MainNotifier>(
      builder: (consumerContext, notifier, __) {
        final canShowAds = widget.args?.canShowAds ?? true;
        if (notifier.isloading) {
          Future.delayed(const Duration(milliseconds: 500), () {
            notifier.isloading = false;
            setState(() {});
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
                        child: notifier.mainScreen(context, canShowAds, keyPostButton),
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
                                    print("==== has ${notifier.scrollController.hasClients}");
                                    if (notifier.scrollController.hasClients) {
                                      if (globalTultipShow) {
                                        return;
                                      }
                                      if (mounted) {
                                        homeClick = true;
                                        if (notifier.scrollController.offset > 0) {
                                          notifier.scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.ease);
                                        }
                                      }
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
                      // bottomNavigationBar: BottomNavigationBar(
                      //   landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
                      //   showSelectedLabels: false,
                      //   showUnselectedLabels: false,
                      //   elevation: 0.5,
                      //   onTap: (int index) async {
                      //     if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
                      //     if (index != 2) {
                      //       setState(() {
                      //         notifier.pageIndex = index;
                      //       });
                      //     } else {
                      //       await notifier.onShowPostContent(consumerContext);
                      //     }
                      //   },
                      //   currentIndex: notifier.pageIndex,
                      //   type: BottomNavigationBarType.fixed,
                      //   items: [
                      //     BottomNavigationBarItem(
                      //       icon: CustomIconWidget(
                      //         defaultColor: false,
                      //         color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                      //         iconData: '${AssetPath.vectorPath}home.svg',
                      //       ),
                      //       activeIcon: const CustomIconWidget(defaultColor: false, color: kHyppeTextLightPrimary, iconData: '${AssetPath.vectorPath}home-active.svg'),
                      //       label: '',
                      //     ),
                      //     BottomNavigationBarItem(
                      //       icon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}search-nav.svg'),
                      //       label: '',
                      //       activeIcon: const CustomIconWidget(defaultColor: false, color: kHyppeTextLightPrimary, iconData: '${AssetPath.vectorPath}search-active.svg'),
                      //     ),
                      //     const BottomNavigationBarItem(
                      //       icon: CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}hyppe-button.svg'),
                      //       label: '',
                      //       activeIcon: CustomIconWidget(defaultColor: false, iconData: '${AssetPath.vectorPath}hyppe-button.svg'),
                      //     ),
                      //     BottomNavigationBarItem(
                      //       icon: Stack(children: [
                      //         CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}notification.svg'),
                      //         const NotificationCircle()
                      //       ]),
                      //       label: '',
                      //       activeIcon: const CustomIconWidget(
                      //         defaultColor: false,
                      //         color: kHyppeTextLightPrimary,
                      //         iconData: '${AssetPath.vectorPath}notification-active.svg',
                      //       ),
                      //     ),
                      //     const BottomNavigationBarItem(
                      //       icon: Profile(),
                      //       label: '',
                      //     ),
                      //     // BottomNavigationBarItem(
                      //     //   icon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}message.svg'),
                      //     //   activeIcon: CustomIconWidget(
                      //     //     defaultColor: false,
                      //     //     color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                      //     //     iconData: '${AssetPath.vectorPath}message-active.svg',
                      //     //   ),
                      //     //   label: '',
                      //     // ),
                      //   ],
                      // ),
                    );
                  },
                ),
              );
      },
    );
  }

  void tapMenu(int index, MainNotifier notifier, consumerContext) async {
    if (notifier.pageIndex == 0) {
      isPagePict = true;
    } else {
      isPagePict = false;
    }
    String newUser = SharedPreference().readStorage(SpKeys.newUser) ?? '';
    print("new user $newUser -- $globalTultipShow");
    if (newUser == "TRUE" || globalTultipShow) {
      return;
    }
    if ((Routing.navigatorKey.currentContext ?? context).read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
    final bool? isGuest = SharedPreference().readStorage(SpKeys.isGuest);
    if (index != 2) {
      if (index == 3) {
        if (isGuest ?? false) {
          isactivealiplayer = true;
          ShowBottomSheet().onLoginApp(Routing.navigatorKey.currentContext ?? context);
        } else {
          setState(() {
            'pageIndex now: $index'.logger();
            notifier.pageIndex = index;
          });
        }
      } else if (index == 0) {
        setState(() {
          notifier.pageIndex = index;
        });
      } else if (index == 1) {
        setState(() {
          notifier.pageIndex = index;
        });
      } else if (index == 4) {
        setState(() {
          notifier.pageIndex = index;
        });
        if (isGuest ?? false) {
          isactivealiplayer = true;
          ShowBottomSheet().onLoginApp(Routing.navigatorKey.currentContext ?? context);
        }
      } else {
        setState(() {
          'pageIndex now: $index'.logger();
          // notifier.pageIndex = index;
        });
      }
    } else {
      MyAudioService.instance.pause();
      if (isGuest ?? false) {
        isactivealiplayer = true;
        ShowBottomSheet().onLoginApp(Routing.navigatorKey.currentContext ?? context).whenComplete(() {
          print("----index $isPagePict");
          if (isPagePict) {
            MyAudioService.instance.playagain(false);
          }
        });
      } else {
        isactivealiplayer = true;
        print('Disini objectnya');
        PreUploadContentNotifier pn = (Routing.navigatorKey.currentContext ?? context).read<PreUploadContentNotifier>();
        pn.hastagChallange = '';
        notifier.onShowPostContent(consumerContext).then((value) {
          print(value);
        });
      }
    }
  }
}
