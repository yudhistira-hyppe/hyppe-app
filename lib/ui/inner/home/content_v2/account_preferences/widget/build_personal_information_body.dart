import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/text_input_account_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BuildPersonalInformationBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance
        .setCustomKey('layout', 'BuildPersonalInformationBody');
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16.0),
        child: Column(
          children: [
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}calendar.svg"),
                ),
                TextInputAccountPreferences(
                  controller: notifier.dobController,
                  labelText: notifier.language.dateOfBirth,
                  hintText: notifier.language.dateOfBirth,
                  readOnly: true,
                  onTap: () =>
                      ShowGeneralDialog.accountPreferencesBirthDropDown(
                          context),
                ),
              ],
            ),
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}phone.svg"),
                ),
                TextInputAccountPreferences(
                  hintText: notifier.language.phoneNumber,
                  labelText: notifier.language.phoneNumber,
                  controller: notifier.mobileController,
                  inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                  textInput: TextInputType.number,
                  maxLength: 15,
                  counterText: false,
                ),
              ],
            ),
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: RotatedBox(
                    quarterTurns: -45,
                    child: CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}back-arrow.svg"),
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
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: RotatedBox(
                    quarterTurns: -45,
                    child: CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                  ),
                ),
                TextInputAccountPreferences(
                  controller: notifier.countryController,
                  labelText: "${notifier.language.country}*",
                  hintText: notifier.language.country,
                  readOnly: true,
                  onTap: () => ShowGeneralDialog
                      .userCompleteProfileLocationCountryDropDown(context,
                          onSelected: (value) =>
                              notifier.locationCountryListSelected(value)),
                ),
              ],
            ),
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: RotatedBox(
                    quarterTurns: -45,
                    child: CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                  ),
                ),
                TextInputAccountPreferences(
                  controller: notifier.areaController,
                  labelText: notifier.language.provinceRegion,
                  hintText: notifier.language.provinceRegion,
                  readOnly: true,
                  onTap: notifier.countryController.text.isEmpty
                      ? () => print("Please choose country first")
                      : () => ShowGeneralDialog
                              .userCompleteProfileLocationProvinceDropDown(
                            context,
                            country: notifier.countryController.text,
                            onSelected: (value) =>
                                notifier.locationProvinceListSelected(value),
                          ),
                ),
              ],
            ),
            Stack(
              children: [
                const Align(
                  alignment: Alignment(0.975, 1),
                  heightFactor: 2.25,
                  child: RotatedBox(
                    quarterTurns: -45,
                    child: CustomIconWidget(
                        iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                  ),
                ),
                TextInputAccountPreferences(
                  controller: notifier.cityController,
                  labelText: notifier.language.locationInThisCountryRegion,
                  hintText: notifier.language.locationInThisCountryRegion,
                  readOnly: true,
                  onTap: notifier.areaController.text.isEmpty
                      ? () => print("Please choose province first")
                      : () => ShowGeneralDialog
                              .userCompleteProfileLocationCityDropDown(
                            context,
                            province: notifier.areaController.text,
                            onSelected: (value) =>
                                notifier.locationCityListSelected(value),
                          ),
                ),
              ],
            ),
            eightPx,
            ListTile(
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 10,
              shape: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).iconTheme.color ?? Colors.white,
                      width: 0.2)),
              onTap: () {
                notifier.getListDeleteOption();
                notifier.navigateToDeleteProfile();
              },
              leading: const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}delete.svg",
              ),
              title: CustomTextWidget(
                textToDisplay: notifier.language.deleteAccount ?? '',
                textStyle: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.start,
              ),
            )
          ],
        ),
      ),
    );
  }
}
