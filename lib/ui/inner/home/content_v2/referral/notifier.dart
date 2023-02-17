import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/register_referral_argument.dart';
import 'package:hyppe/core/bloc/referral/bloc.dart';
import 'package:hyppe/core/bloc/referral/state.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/core/models/collection/referral/model_referral.dart';
import 'package:hyppe/core/services/shared_preference.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ux/routing.dart';

class ReferralNotifier extends LoadingNotifier with ChangeNotifier {
  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  String _referralLink = "";
  String _referralLinkText = "";
  String _referralCount = "0";
  ModelReferral? _modelReferral;
  String get referralLink => _referralLink;
  String get referralLinkText => _referralLinkText;
  String get referralCount => _referralCount;
  String _nameReferral = '';
  ModelReferral? get modelReferral => _modelReferral;
  String get nameReferral => _nameReferral;

  bool buttonReferralDisable() => _nameReferral.isNotEmpty ? true : false;

  set inserReferral(val) {
    _nameReferral = val;
    notifyListeners();
  }

  set referralCount(val) {
    _referralCount = val.toString();
    notifyListeners();
  }

  set modelReferral(val) {
    _modelReferral = val;
    notifyListeners();
  }

  set referralLink(val) {
    _referralLink = val;
    _referralLinkText = "Hei, Ayo bergabung dan berkreasi di Hyppe!\nJelajahi Dan Tuangkan Ide Kreatifmu Di Mobile Hyppe App Sekarang!\n\n$val";
    notifyListeners();
  }

  Future onInitial(BuildContext context) async {
    var _result = await System().createdReferralLink(context);
    debugPrint("REFERRAL => " + _result.toString());
    referralLink = _result.toString();

    final referralBloc = ReferralBloc();
    await referralBloc.getReferralCount(context);
    final referralFetch = referralBloc.referralFetch;

    if (referralFetch.referralState == ReferralState.getReferralUserSuccess) {
      referralCount = referralFetch;
      modelReferral = ModelReferral.fromJson(referralFetch.data);
      print('heheh ${modelReferral?.data}');
    }
  }

  void _showSnackBar(BuildContext context, Color color, String message, String desc) {
    Routing _routing = Routing();
    ShowBottomSheet().onShowColouredSheet(
      context,
      message,
      color: color,
      subCaption: desc,
      iconSvg: "${AssetPath.vectorPath}remove.svg",
    );
    // _routing.showSnackBar(
    //   snackBar: SnackBar(`
    //     margin: EdgeInsets.zero,
    //     padding: EdgeInsets.zero,
    //     behavior: SnackBarBehavior.floating,
    //     content: SafeArea(
    //       child: SizedBox(
    //         height: 56,
    //         child: OnColouredSheet(
    //           maxLines: 2,
    //           caption: message,
    //           subCaption: desc,
    //           fromSnackBar: true,
    //           iconSvg: "${AssetPath.vectorPath}remove.svg",
    //         ),
    //       ),
    //     ),
    //     backgroundColor: color,
    //   ),
    // );
  }

  @override
  void setLoading(bool val, {bool setState = true, Object? loadingObject}) {
    super.setLoading(val, loadingObject: loadingObject);
    if (setState) notifyListeners();
  }

  Future registerReferral(BuildContext context) async {
    setLoading(true);
    bool connection = await System().checkConnections();
    if (connection) {
      // unFocusController();

      // incorrect = false;
      String realDeviceID = await System().getDeviceIdentifier();
      final notifier = ReferralBloc();

      await notifier.registerReferral(
        context,
        data: System().validateEmail(_nameReferral)
            ? RegisterReferralArgument(
                email: _nameReferral,
                imei: realDeviceID != "" ? realDeviceID : SharedPreference().readStorage(SpKeys.fcmToken),
              )
            : RegisterReferralArgument(
                username: _nameReferral,
                imei: realDeviceID != "" ? realDeviceID : SharedPreference().readStorage(SpKeys.fcmToken),
              ),
        withAlertConnection: false,
        // function: () => onClickLogin(context),
      );
      setLoading(false);

      print(RegisterReferralArgument);

      final fetch = notifier.referralFetch;
      if (fetch.referralState == ReferralState.referralUserSuccess) {
        await onInitial(context);
        Routing().moveBack();
        _showSnackBar(context, kHyppeTextSuccess, 'Success', 'username referal berhasil digunakan');
      }
      if (fetch.referralState == ReferralState.referralUserError) {
        _showSnackBar(context, kHyppeDanger, 'Gagal', '${fetch.message['info'][0]}');
      }
    } else {
      setLoading(false);
      ShowBottomSheet.onNoInternetConnection(context, tryAgainButton: () => Routing().moveBack());
    }
  }
}
