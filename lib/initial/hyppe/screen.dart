import 'package:hyppe/core/services/route_observer_service.dart';
import 'package:hyppe/initial/hyppe/multi_provider.dart';
import 'package:hyppe/initial/hyppe/notifier.dart';
import 'package:hyppe/initial/life_cycle_manager/life_cycle_manager.dart';
import 'package:hyppe/ux/generate.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app.dart';

class Hyppe extends StatefulWidget {
  @override
  State<Hyppe> createState() => _HyppeState();
}

class _HyppeState extends State<Hyppe> {
  final hyppeNotifier = HyppeNotifier();

  @override
  void initState() {
    hyppeNotifier.setInitialTheme();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppDependencies.inject(rootNotifier: hyppeNotifier),
      child: LifeCycleManager(
        child: Selector<HyppeNotifier, ThemeData?>(
          selector: (_, select) => select.themeData,
          builder: (_, theme, __) {
            return MaterialApp(
              key: materialAppKey,
              title: "Hyppe",
              theme: theme,
              navigatorObservers: [
                CustomRouteObserver(),
                CustomRouteObserver.routeObserver,
              ],
              onGenerateInitialRoutes: Generate.initialRoute,
              onGenerateRoute: Generate.allRoutes,
              debugShowCheckedModeBanner: false,
              navigatorKey: Routing.navigatorKey,
              scaffoldMessengerKey: Routing.scaffoldMessengerKey,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child ?? Container(),
              ),
            );
          },
        ),
      ),
    );
  }
}
