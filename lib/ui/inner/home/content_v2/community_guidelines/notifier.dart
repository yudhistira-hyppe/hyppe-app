import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/live_stream/bloc.dart';
import 'package:hyppe/core/bloc/live_stream/state.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/models/collection/utils/community_guideline/community_guideline_model.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class CommunityGuidelinesNotifier with ChangeNotifier {
  bool isloading = false;
  CommunityGuidelinesModel? cguidelineData;

  Future getGuidelines(BuildContext context, bool mounted, String name) async {
    isloading = true;
    notifyListeners();
    bool connect = await System().checkConnections();

    if (connect) {
      try {
        final notifier = LiveStreamBloc();
        Map data = {
          "page": 0,
          "limit": 9999,
          "descending": true,
          "name": name,
          "status": ["APPROVED"],
          "isActive": true
        };

        if (mounted) await notifier.getLinkStream(context, data, UrlConstants.guidlineList);

        final fetch = notifier.liveStreamFetch;
        if (fetch.postsState == LiveStreamState.getApiSuccess) {
          if (fetch.data != null) {
            cguidelineData = CommunityGuidelinesModel.fromJson(fetch.data[0]);
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
