
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/gift/activation/bloc.dart';
import 'package:hyppe/core/bloc/gift/activation/state.dart';
import 'package:hyppe/core/bloc/gift/status_activation/bloc.dart';
import 'package:hyppe/core/bloc/gift/status_activation/state.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/services/shared_preference.dart';

import 'widgets/dialog_info.dart';
import 'widgets/dialog_warning.dart';

class ActivationGiftNotifier extends ChangeNotifier {
  final bloc = GiftDataBloc();
  final blocActivation = ActivationGiftDataBloc();

  //Check Gift Activaction
  bool _giftActivation = false;
  bool get giftActivation => _giftActivation;
  set giftActivation(bool? val) {
    _giftActivation = val??false;
    notifyListeners();
  }

  //Check Posting Content > 0
  bool _countContent = false;
  bool get countContent => _countContent;
  set countContent(bool? val) {
    _countContent = val??false;
    notifyListeners();
  }

  Future initPage() async {
    final userGift = SharedPreference().readStorage(SpKeys.statusGiftActivation);
    giftActivation = userGift;
  }

  Future checkPosts(BuildContext context, mounted) async {
    try{
      await bloc.getGift(context);
      if (bloc.dataFetch.dataState == GiftState.getBlocSuccess) {
        countContent = bloc.dataFetch.data;
        if (countContent){
          // giftActivation = countContent;

          if (!mounted) return;

          await activationGif(context);
        }
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }

  Future activationGif(BuildContext context) async {
    try{
      await blocActivation.postActivationGift(context, activation: !giftActivation);
      if (blocActivation.dataFetch.dataState == ActivationGiftState.getBlocSuccess) {
        giftActivation = !giftActivation;
        SharedPreference().writeStorage(SpKeys.statusGiftActivation, giftActivation);
      }
    }catch(_){
      debugPrint(_.toString());
    }
  }

  void showButtomSheetInfo(BuildContext context, LocalizationModelV2 lang) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DialogInfoWidget(lang: lang,);
        }
    );
  }

  void showButtomSheetWaring(BuildContext context, LocalizationModelV2 lang) {
    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DialogWarningWidget(lang: lang,);
        }
    );
  }
  
}