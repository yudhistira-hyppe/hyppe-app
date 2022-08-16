import 'dart:async' show Timer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/extension/log_extension.dart';

import 'package:hyppe/core/bloc/device/bloc.dart';
import 'package:hyppe/core/services/check_version.dart';

import 'package:hyppe/core/services/socket_service.dart';
import 'package:hyppe/core/services/isolate_service.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/dynamic_link_service.dart';

import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/general_dialog_content/permanently_denied_permisson_content.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget? child;

  const LifeCycleManager({Key? key, this.child}) : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver {
  Timer? _timerLink;
  final _socketService = SocketService();
  final _isolateService = IsolateService();

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    _timerLink = Timer(const Duration(seconds: 2), () => DynamicLinkService.handleDynamicLinks());
    _isolateService.turnOnWorkers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
    _timerLink?.cancel();
    if (_socketService.isRunning) _socketService.closeSocket();
    if (_isolateService.workerActive()) _isolateService.turnOffWorkers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final activity = DeviceBloc();

    if (state == AppLifecycleState.inactive) {
      "App Inactive".logger();
    }
    if (state == AppLifecycleState.resumed) {
      "App Resumed".logger();
      final _userToken = SharedPreference().readStorage(SpKeys.userToken);

      if (_userToken != null) {
        try {
          await activity.activityAwake(context);
          //cek version aplikasi
          await CheckVersion().check(context, activity.deviceFetch.version);
        } catch (e) {
          e.logger();
        }
      }
      _timerLink = Timer(const Duration(milliseconds: 1000), () => DynamicLinkService.handleDynamicLinks());
    }
  }

  @override
  Widget build(_) => widget.child!;
}
