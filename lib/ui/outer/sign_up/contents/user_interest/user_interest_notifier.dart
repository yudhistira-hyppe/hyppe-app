import 'package:flutter/foundation.dart';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/bloc/utils_v2/state.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import '../../../../../core/models/collection/search/search_content.dart';

class UserInterestNotifier extends ChangeNotifier with LoadingNotifier {
  final _routing = Routing();
  final _bottomSheet = ShowBottomSheet();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  List<String> _interestData = [];
  List<Interest> _interest = [];

  List<Interest> get interest => _interest;

  set interestData(List<String> val) {
    _interestData = [];
    notifyListeners();
  }

  Color interestNextButtonColor(BuildContext context, List<String> userInterested) {
    if (!listEquals(_interestData, userInterested) && _interestData.isNotEmpty && !isLoading) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surface;
    }
  }

  TextStyle? interestNextTextColor(BuildContext context, List<String> userInterested) {
    if (!listEquals(_interestData, userInterested) && _interestData.isNotEmpty) {
      return Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText);
    } else {
      return Theme.of(context).primaryTextTheme.button;
    }
  }

  Future onTapInterestButton(BuildContext context, bool fromSetting, List<String> userInterested) async {
    print('simpan kesuakan');
    if (_interestData.isNotEmpty) {
      print('dari setting');
      if (fromSetting) {
        if (!listEquals(_interestData, userInterested)) {
          final notifier = Provider.of<AccountPreferencesNotifier>(context, listen: false);
          await notifier.onClickSaveInterests(context, _interestData);
        }
      } else {
        print('bukan dari setting');
        final notifier = Provider.of<AccountPreferencesNotifier>(context, listen: false);
        await notifier.onClickSaveInterests(context, _interestData);
        _routing.move(Routes.signUpWelcome);
      }
    }
  }

  Function? interestSkipButton() {
    if (_interestData.isEmpty) {
      return () {
        _routing.move(Routes.signUpWelcome);
      };
    } else {
      return null;
    }
  }

  Function? insertInterest(int index) {
    print(index);
    print(interest.isNotEmpty);
    if (interest.isNotEmpty) {
      String tile = interest[index].id ?? '';
      print(tile);
      return () {
        if (_interestData.contains(tile)) {
          _interestData.removeWhere((v) => v == tile);
        } else {
          _interestData.add(tile);
        }
        print(_interestData);
        notifyListeners();
      };
    } else {
      return null;
    }
  }

  bool onBackPress(bool fromSetting) {
    if(fromSetting){
      return true;
    }else{
      return false;
    }
    fromSetting ? _routing.moveBack() : _routing.moveAndPop(Routes.login);
    return true;
  }

  bool pickedInterest(String? tile) => _interestData.contains(tile) ? true : false;
  bool checkedInterest() => _interestData.isNotEmpty ? true : false;
  Future onGetInterest(BuildContext context) async {
    final notifier = UtilsBlocV2();
    await notifier.getInterestBloc(context);
    final fetch = notifier.utilsFetch;
    if (fetch.utilsState == UtilsState.getInterestsSuccess) {
      _interest = [];
      fetch.data.forEach((v) => _interest.add(Interest.fromJson(v)));
      notifyListeners();
    }
  }

  initUserInterest(BuildContext context, UserInterestScreenArgument arguments) async {
    if (arguments.fromSetting) {
      _interestData = [];
      _interestData.addAll(arguments.userInterested);
    } else {
      await _bottomSheet.onShowLicenseAgreementSheet(context);
    }
  }

  void goToEula() => _routing.move(Routes.userAgreement);
}
