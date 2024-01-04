import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:hyppe/core/arguments/contents/user_interest_screen_argument.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/general_dialog/show_general_dialog.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/self_profile/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/profile/setting/widget/my_balance.dart';
import 'package:hyppe/ui/inner/main/notifier.dart';
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
import 'package:showcaseview/showcaseview.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  GlobalKey keyTransaction = GlobalKey();
  GlobalKey keyReferral = GlobalKey();
  MainNotifier? mn;
  int indexKey = 0;
  int indexreferral = 0;
  var myContext;

  @override
  void initState() {
    super.initState();
    mn = Provider.of<MainNotifier>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mn?.tutorialData.isNotEmpty ?? [].isEmpty) {
        setState(() {
          indexKey = mn?.tutorialData.indexWhere((element) => element.key == 'transaction') ?? 0;
          indexreferral = mn?.tutorialData.indexWhere((element) => element.key == 'idRefferal') ?? 0;
        });
        if (mn?.tutorialData[indexKey].status == false || mn?.tutorialData[indexreferral].status == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ShowCaseWidget.of(myContext).startShowCase([keyTransaction, keyReferral]));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'SettingScreen');
    final theme = Theme.of(context);
    return Consumer<TranslateNotifierV2>(
      builder: (context, notifier, child) => ShowCaseWidget(
        onStart: (index, key) {
          print('onStart: $index, $key');
        },
        onComplete: (index, key) {
          print('onComplete: $index, $key');
        },
        blurValue: 0,
        disableBarrierInteraction: true,
        disableMovingAnimation: true,
        builder: Builder(builder: (context) {
          myContext = context;
          return Scaffold(
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
                    onTap: (){
                      context.handleActionIsGuest((){
                        context.read<SettingNotifier>().validateUser(context, notifier);
                      });
                    },
                    caption: '${notifier.translate.transaction}',
                    keyGLobal: keyTransaction,
                    descriptionCas: (mn?.tutorialData.isEmpty ?? [].isEmpty)
                        ? ''
                        : notifier.translate.localeDatetime == 'id'
                            ? mn?.tutorialData[indexKey].textID
                            : mn?.tutorialData[indexKey].textEn,
                    positionTooltip: TooltipPosition.bottom,
                    positionYplus: -10,
                    indexTutor: indexKey,
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
                        onTap: (){
                          context.handleActionIsGuest((){
                            Routing().move(Routes.accountPreferences);
                          });
                        },
                        caption: '${notifier.translate.accountPreference}',
                      ),
                      SettingTile(
                        icon: 'lock.svg',
                        onTap: () {
                          context.handleActionIsGuest((){
                            Routing().move(Routes.homePageSignInSecurity);
                          });
                        },
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
                        onTap: (){
                          context.handleActionIsGuest((){
                            Routing().move(Routes.referralScreen);
                          });
                        },
                        icon: 'person-plus.svg',
                        caption: '${notifier.translate.referralID}',
                        keyGLobal: keyReferral,
                        descriptionCas: (mn?.tutorialData.isEmpty ?? [].isEmpty)
                            ? ''
                            : notifier.translate.localeDatetime == 'id'
                                ? mn?.tutorialData[indexreferral].textID
                                : mn?.tutorialData[indexreferral].textEn,
                        positionTooltip: TooltipPosition.top,
                        positionYplus: 25,
                        indexTutor: indexreferral,
                      ),
                      // SettingTile(
                      //   onTap: () => Routing().move(Routes.contentPreferences),
                      //   icon: 'person-plus.svg',
                      //   caption: '${notifier.translate.referralID}',
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
                    headerCaption: '${notifier.translate.storage}',
                    tiles: [
                      SettingTile(
                        caption: notifier.translate.cacheAndDownload ?? "",
                        icon: 'storage-icon.svg',
                        onTap: () => Routing().move(Routes.cacheAndDownload),
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
          );
        }),
      ),
    );
  }
}
