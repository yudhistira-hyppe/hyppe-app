import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/services/overlay_service/overlay_handler.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ui/inner/main/widget/notification_circle.dart';

import '../../../core/constants/shared_preference_keys.dart';
import '../../../core/services/route_observer_service.dart';
import '../../../core/services/shared_preference.dart';
import '../../constant/widget/after_first_layout_mixin.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware, AfterFirstLayoutMixin {
  late MainNotifier _mainNotifier;

  @override
  void initState() {
    _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
    _mainNotifier.initMain(context);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    CustomRouteObserver.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPop() {
    print('didPop isOnHomeScreen false');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.didPop();
  }

  @override
  void didPush() {
    Future.delayed(Duration(seconds: 1), (){
      print('didPush isOnHomeScreen true');
      SharedPreference().writeStorage(SpKeys.isOnHomeScreen, true);
    });
    super.didPush();
  }

  @override
  void didPopNext() {
    Future.delayed(Duration(seconds: 1), (){
      print('didPopNext isOnHomeScreen true');
      SharedPreference().writeStorage(SpKeys.isOnHomeScreen, true);
    });
    super.didPopNext();
  }

  @override
  void didPushNext() {
    print('didPushNext isOnHomeScreen false');
    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.didPushNext();
  }

  @override
  void dispose() {
    CustomRouteObserver.routeObserver.unsubscribe(this);
    // print('isOnHomeScreen false');
    // SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final _themes = Theme.of(context);
    return Consumer<MainNotifier>(
      builder: (_, notifier, __) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: _themes.backgroundColor,
            body: AnimatedSwitcher(
              child: notifier.mainScreen(context),
              duration: const Duration(milliseconds: 250),
            ),
            bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 0.5,
              onTap: (int index) {
                if (context.read<OverlayHandlerProvider>().overlayActive) context.read<OverlayHandlerProvider>().removeOverlay(context);
                setState(() {
                  if (index != 2) {
                    notifier.pageIndex = index;
                  } else {
                    notifier.onShowPostContent(context);
                    print('onShowPostContent isOnHomeScreen false');
                    SharedPreference().writeStorage(SpKeys.isOnHomeScreen, false);
                  }
                });
              },
              currentIndex: notifier.pageIndex,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: CustomIconWidget(
                    defaultColor: false,
                    color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                    iconData: '${AssetPath.vectorPath}home.svg',
                  ),
                  activeIcon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}home-active.svg'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}search-nav.svg'),
                  label: '',
                  activeIcon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}search-active.svg'),
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.selectedIconTheme?.color, iconData: '${AssetPath.vectorPath}upload.svg'),
                  label: '',
                  activeIcon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.selectedIconTheme?.color, iconData: '${AssetPath.vectorPath}upload.svg'),
                ),
                BottomNavigationBarItem(
                  icon: Stack(children: [
                    CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}notification.svg'),
                    const NotificationCircle()
                  ]),
                  label: '',
                  activeIcon: CustomIconWidget(
                    defaultColor: false,
                    color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                    iconData: '${AssetPath.vectorPath}notification-active.svg',
                  ),
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(defaultColor: false, color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color, iconData: '${AssetPath.vectorPath}message.svg'),
                  activeIcon: CustomIconWidget(
                    defaultColor: false,
                    color: _themes.bottomNavigationBarTheme.unselectedIconTheme?.color,
                    iconData: '${AssetPath.vectorPath}message-active.svg',
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    CustomRouteObserver.routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }
}
