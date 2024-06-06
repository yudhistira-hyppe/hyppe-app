import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/arguments/general_argument.dart';
import 'package:hyppe/core/bloc/live_stream/bloc.dart';
import 'package:hyppe/core/bloc/live_stream/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/models/collection/live_stream/banned_stream_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

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
          // "idStream": dataBanned.streamId,
          "title": title,
          "messages": messages,
        };

        if (mounted) await notifier.getLinkStream(context, data, UrlConstants.appealStream);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          context.read<StreamerNotifier>().destoryPusher();
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          Routing().moveReplacement(Routes.appealLiveSuccess, argument: GeneralArgument(isTrue: true));
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

  bool isloading = false;

  Future checkBeforeLive(BuildContext context, mounted) async {
    isloading = true;
    notifyListeners();
    bool connect = await System().checkConnections();
    if (connect) {
      try {
        final notifier = LiveStreamBloc();

        if (mounted) {
          await notifier.getStream(context, UrlConstants.checkStream);
        }
        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          if (fetch.statusStream == false) {
            dataBanned = BannedStreamModel.fromJson(fetch.data);
            if (dataBanned.statusAppeal ?? false) {
              Routing().moveReplacement(Routes.appealLiveSuccess, argument: GeneralArgument(isTrue: false));
            }
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      notifyListeners();
    } else {
      if (context.mounted) {
        ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
          Routing().moveBack();
        });
      }
    }
    isloading = false;
    notifyListeners();
  }
}
