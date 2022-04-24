import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/utils_v2/bloc.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/entities/loading/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ProfileCompletionNotifier extends LoadingNotifier with ChangeNotifier {
  final TextEditingController dobController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final _routing = Routing();

  LocalizationModelV2 language = LocalizationModelV2();
  translate(LocalizationModelV2 translate) {
    language = translate;
    notifyListeners();
  }

  notifyNotifier() => notifyListeners();
  void onInitial(BuildContext context) {
    _clearTxt();
    final notifierData =
        Provider.of<SelfProfileNotifier>(context, listen: false);
    fullNameController.text = notifierData.user.profile?.fullName ?? "";
    genderController.text = notifierData.user.profile?.gender ?? "";
    dobController.text = notifierData.user.profile?.dob ?? "";
  }

  void _clearTxt() {
    fullNameController.clear();
    genderController.clear();
    dobController.clear();
  }

  bool somethingChanged(BuildContext context) {
    final notifierData =
        Provider.of<SelfProfileNotifier>(context, listen: false);
    return (fullNameController.text != notifierData.user.profile?.fullName ||
            genderController.text != notifierData.user.profile?.gender ||
            dobController.text != notifierData.user.profile?.dob) &&
        fullNameController.text.isNotEmpty;
  }

  Function()? genderOnTap(BuildContext context) => () {
        ShowBottomSheet.onShowOptionGender(
          context,
          onSave: () {
            _routing.moveBack();
            Provider.of<AccountPreferencesNotifier>(context, listen: false)
                .genderController
                .text = genderController.text;
            notifyListeners();
          },
          onCancel: () {
            Routing().moveBack();
            FocusScope.of(context).unfocus();
          },
          onChange: (value) {
            genderController.text = value;
            notifyListeners();
          },
          value: genderController.text,
          initFuture: UtilsBlocV2().getGenderBloc(context),
        );
      };
}
