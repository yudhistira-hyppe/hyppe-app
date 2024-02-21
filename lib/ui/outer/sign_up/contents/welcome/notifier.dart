import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart' as V2;
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/utils/welcome/welcome.dart';
import 'package:hyppe/core/models/collection/utils/welcome/welcome_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:dynamic_widget/dynamic_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

class SignUpWelcomeNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  WelcomeData? _result;
  WelcomeData? get result => _result;
  set result(WelcomeData? val) {
    _result = val;
    notifyListeners();
  }

  initWelcome(BuildContext context) async {
    bool connection = await System().checkConnections();
    if (connection) {
      final _mainNotifier = Provider.of<MainNotifier>(context, listen: false);
      await _mainNotifier.initMain(context, onUpdateProfile: true);

      final notifier = UtilsBlocV2();
      await notifier.getWelcomeNotesBloc(context);
      final fetch = notifier.utilsFetch;
      if (fetch.utilsState == V2.UtilsState.welcomeNotesSuccess) {
        final Welcome _dynamic = fetch.data;
        result = _dynamic.data[0];
        notifyListeners();
      }
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        Routing().moveBack();
        initWelcome(context);
      });
    }
  }
}

class DefaultClickListener implements ClickListener {
  @override
  void onClicked(String? event) {
    print("Receive click event: $event");
  }
}
