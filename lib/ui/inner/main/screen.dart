import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/app.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/inner/home/widget/profile.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/main/widget/notification_circle.dart';

import '../../../core/arguments/main_argument.dart';
import '../../../core/constants/shared_preference_keys.dart';
import '../../../core/services/shared_preference.dart';

class MainScreen extends StatefulWidget {
  MainArgument? args;
  MainScreen({Key? key, this.args}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late MainNotifier _mainNotifier;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'MainScreen');
    _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
    _mainNotifier.initMain(context, isInitSocket: true);
    SharedPreference().writeStorage(SpKeys.isShowPopAds, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    return Consumer<MainNotifier>(
      builder: (consumerContext, notifier, __) {
        final canShowAds = widget.args?.canShowAds ?? true;
        return Scaffold(
          backgroundColor: _themes.backgroundColor,
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: notifier.mainScreen(context, canShowAds),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {},
          //   tooltip: 'Increment',
          //   elevation: 4.0,
          //   child: CustomIconWidget(
          //     defaultColor: false,
          //     // color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
          //     iconData: '${AssetPath.vectorPath}hyppe-button.svg',
          //     height: 50,
          //   ),
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
          bottomNavigationBar: BottomAppBar(
            color: kHyppeLightSurface,
            height: Platform.isIOS ? 135 : 100,
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
                    onPressed: () {
                      if (notifier.pageIndex == 0) {
                        notifier.scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.elasticOut);
                      } else {
                        tapMenu(0, notifier, consumerContext);
                      }
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
                      tapMenu(1, notifier, consumerContext);
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      tapMenu(2, notifier, consumerContext);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: CustomIconWidget(
                        defaultColor: false,
                        iconData: '${AssetPath.vectorPath}hyppe-button.svg',
                      ),
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
                      tapMenu(4, notifier, consumerContext);
                    },
                  ),
                ),
              ],
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
    );
  }

  void tapMenu(int index, MainNotifier notifier, consumerContext) async {
    if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
    if (index != 2) {
      setState(() {
        notifier.pageIndex = index;
      });
    } else {
      await notifier.onShowPostContent(consumerContext);
    }
  }
}
