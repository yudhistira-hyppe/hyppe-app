import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/live_stream/bloc.dart';
import 'package:hyppe/core/bloc/live_stream/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/models/collection/live_stream/banned_stream_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class AppealStreamNotifier with ChangeNotifier {
  BannedStreamModel _dataBanned = BannedStreamModel();
  BannedStreamModel get dataBanned => _dataBanned;

  bool loadingAppel = false;

  set dataBanned(BannedStreamModel val) {
    _dataBanned = val;
    notifyListeners();
  }

  Future submitAppeal(BuildContext context, mounted, String title, String messages) async {
    loadingAppel = true;
    notifyListeners();
    var dataReturn;
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();

        Map data = {
          "idStream": dataBanned.streamId,
          "title": title,
          "messages": messages,
        };

        if (mounted) await notifier.getLinkStream(context, data, UrlConstants.appealStream);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          Routing().move(Routes.appealLiveSuccess);
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      // returnNext = false;
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
          submitAppeal(context, mounted, title, messages);
        });
      }
    }
    loadingAppel = false;
    notifyListeners();
    return dataReturn;
  }
}
