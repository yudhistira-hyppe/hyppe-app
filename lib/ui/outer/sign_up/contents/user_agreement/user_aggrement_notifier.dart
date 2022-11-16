import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart' as V2;
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ux/routing.dart';
// import 'package:provider/provider.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/core/models/collection/utils/eula/eula.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

class UserAgreementNotifier extends ChangeNotifier with LoadingNotifier {
  final _routing = Routing();
  final _sharedPreferences = SharedPreference();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  Eula? _eula;
  String? _eulaID;

  Eula? get eula => _eula;
  String? get eulaID => _eulaID;

  set eulaID(String? val) {
    _eulaID = val;
    notifyListeners();
  }

  set eula(Eula? val) {
    _eula = val;
    notifyListeners();
  }

  Color nextButtonColor(BuildContext context, bool state) {
    if (state) {
      return Theme.of(context).colorScheme.primaryVariant;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle nextTextColor(BuildContext context, bool state) {
    if (state) {
      return Theme.of(context).textTheme.button ?? const TextStyle();
    } else {
      return Theme.of(context).textTheme.button?.copyWith(color: Theme.of(context).colorScheme.secondaryVariant) ?? const TextStyle();
    }
  }

  Future initEula(BuildContext context) async {
    bool connection = await System().checkConnections();
    if (connection) {
      final notifier2 = UtilsBlocV2();

      final _isoCode = _sharedPreferences.readStorage(SpKeys.isoCode) ?? "en";
      setLoading(true);

      await notifier2.getEulaBloc(context);

      final fetch2 = notifier2.utilsFetch;
      if (fetch2.utilsState == V2.UtilsState.getEulaSuccess) {
        _eula = fetch2.data as Eula?;
        _eulaID = _eula?.data[_isoCode == 'en' ? 0 : 1].eulaID;
      }
      setLoading(false);
    } else {
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () {
        _routing.moveBack();
        initEula(context);
      });
    }
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }
}
