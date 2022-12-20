import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/widget/my_balance.dart';
import 'package:hyppe/ux/path.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';

import 'package:hyppe/ui/inner/home/content_v2/profile/setting/setting_notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/widget/setting_tile.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/widget/setting_component.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TranslateNotifierV2>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: theme.textTheme.subtitle1,
            textToDisplay: '${notifier.translate.settings}',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingTile(
                icon: 'transaction-icon.svg',
                onTap: () => context.read<SettingNotifier>().validateUser(context, notifier),
                caption: '${notifier.translate.transaction}',
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: MyBalance(),
              ),
              Divider(
                thickness: 1,
                color: theme.colorScheme.surface,
              ),
              sixteenPx,
              SettingComponent(
                headerCaption: '${notifier.translate.account}',
                tiles: [
                  SettingTile(
                    icon: 'preferensi-account-icon.svg',
                    onTap: () => Routing().move(Routes.accountPreferences),
                    caption: '${notifier.translate.accountPreference}',
                  ),
                  SettingTile(
                    icon: 'lock.svg',
                    onTap: () => Routing().move(Routes.homePageSignInSecurity),
                    caption: '${notifier.translate.signInAndSecurity}',
                  ),
                  SettingTile(
                    onTap: () => Routing().move(Routes.userInterest,
                        argument: UserInterestScreenArgument(
                          fromSetting: true,
                          userInterested: Provider.of<SelfProfileNotifier>(context, listen: false).user.profile?.interest ?? [],
                        )),
                    caption: '${notifier.translate.interest}',
                    icon: 'heart-icon.svg',
                  ),
                  // SettingTile(
                  //   caption: '${notifier.translate.theme}',
                  //   icon: 'theme-icon.svg',
                  //   onTap: () => Routing().move(Routes.themeScreen),
                  // ),
                  SettingTile(
                    onTap: () => ShowGeneralDialog.newAccountLanguageDropDown(context),
                    icon: 'language-icon.svg',
                    caption: '${notifier.translate.language}',
                  ),
                  SettingTile(
                    onTap: () => Routing().move(Routes.referralScreen),
                    icon: 'person-plus.svg',
                    caption: '${notifier.translate.referralID}',
                  ),
                ],
              ),
              sixteenPx,
              Divider(
                thickness: 1,
                color: theme.colorScheme.surface,
              ),
              sixteenPx,
              SettingComponent(
                headerCaption: '${notifier.translate.support}',
                tiles: [
                  SettingTile(
                    caption: System().capitalizeFirstLetter(notifier.translate.help ?? ""),
                    icon: 'help-icon.svg',
                    onTap: () => Routing().move(Routes.help),
                  ),
                  SettingTile(
                    caption: System().capitalizeFirstLetter(notifier.translate.privacyPolicy ?? ""),
                    icon: 'privacy-police-icon.svg',
                    onTap: () => Routing().move(Routes.userAgreement),
                  ),
                  // SettingTile(
                  //   icon: 'terms-icon.svg',
                  //   caption: 'User Agreement',
                  //   onTap: () => Routing().move(userAgreement),
                  // ),
                  // SettingTile(
                  //   onTap: () {},
                  //   caption: 'Language',
                  //   icon: 'language-icon.svg',
                  // ),
                ],
              ),
              sixteenPx,
              Divider(
                thickness: 1,
                color: theme.colorScheme.surface,
              ),
              sixteenPx,
              SettingComponent(
                headerCaption: '${notifier.translate.about}',
                tiles: [
                  SettingTile(
                    icon: 'info-icon.svg',
                    caption: System().capitalizeFirstLetter(notifier.translate.version ?? ""),
                    trailing: Selector<SettingNotifier, String>(
                      builder: (_, value, __) {
                        return CustomTextWidget(
                          textToDisplay: value,
                          textStyle: theme.textTheme.bodyText1,
                        );
                      },
                      selector: (p0, p1) => p1.appPackage ?? '',
                    ),
                  ),
                  SettingTile(
                    onTap: () => ShowBottomSheet.onShowSignOut(
                      context,
                      onSignOut: () {
                        context.read<SettingNotifier>().logOut(context);
                      },
                    ),
                    icon: 'logout-icon.svg',
                    caption: '${notifier.translate.logOut}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
