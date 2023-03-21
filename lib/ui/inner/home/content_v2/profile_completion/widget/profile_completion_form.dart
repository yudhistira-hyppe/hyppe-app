import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/text_input_account_preferences.dart';
import 'package:provider/provider.dart';

class ProfileCompletionForm extends StatelessWidget {
  const ProfileCompletionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ProfileCompletionForm');
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please input the data correctly", style: Theme.of(context).textTheme.titleMedium),
            Text("you will be returned to post setting page after this process is done"),
            fortyPx,
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: CustomIconWidget(iconData: "${AssetPath.vectorPath}calendar.svg"),
                ),
                TextInputAccountPreferences(
                  controller: notifier.dobController,
                  labelText: notifier.language.dateOfBirth,
                  hintText: notifier.language.dateOfBirth,
                  readOnly: true,
                  onTap: () => ShowGeneralDialog.accountPreferencesBirthDropDown(context),
                ),
              ],
            ),
            TextInputAccountPreferences(
              controller: notifier.fullNameController,
              labelText: "${notifier.language.fullName}*",
              hintText: notifier.language.fullName,
            ),
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: RotatedBox(
                    quarterTurns: -45,
                    child: CustomIconWidget(iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                  ),
                ),
                TextInputAccountPreferences(
                  controller: notifier.genderController,
                  labelText: notifier.language.gender,
                  hintText: notifier.language.gender,
                  readOnly: true,
                  onTap: notifier.genderOnTap(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
