import 'package:flutter/material.dart';
import 'package:flutter_livepush_plugin/beauty/live_beauty.dart';
import 'package:flutter_livepush_plugin/live_base.dart';
import 'package:flutter_livepush_plugin/live_push_def.dart';
import 'package:flutter_livepush_plugin/live_pusher.dart';

class Streamer with ChangeNotifier {
  late AlivcBase _alivcBase;
  late AlivcLivePusher _alivcLivePusher;
  late AlivcLiveBeautyManager _beautyManager;

  Future<void> init() async {
    // _setPageOrientation(action, ctx);
    _alivcBase = AlivcBase.init();
    _alivcBase.registerSDK();
    _alivcBase.setObserver();
    _alivcBase.setOnLicenceCheck((result, reason) {
      if (result == AlivcLiveLicenseCheckResultCode.success) {
        // The SDK is registered.
      } else {
        print("======== belum ada lisensi ========");
      }
    });

    // _setLivePusher(action, ctx);
    // _onListen(action, ctx);
  }

  // Future<void> _setPageOrientation(BuildContext ctx) async {
  //   AlivcLivePushOrientation currentOrientation = await ctx.state.pusherConfig.getOrientation();
  //   if (currentOrientation == AlivcLivePushOrientation.landscape_home_left) {
  //     SystemChrome.setPreferredOrientations([
  //       DeviceOrientation.landscapeLeft,
  //     ]);
  //   } else if (currentOrientation == AlivcLivePushOrientation.landscape_home_right) {
  //     SystemChrome.setPreferredOrientations([
  //       DeviceOrientation.landscapeRight,
  //     ]);
  //   }
  // }
}
