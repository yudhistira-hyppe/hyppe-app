import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/account_preference_screen_argument.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/ux/routing.dart';

import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';

import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/build_profile_body.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/button_account_preferences.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/widget/build_personal_information_body.dart';

class HyppeAccountPreferences extends StatefulWidget {
  final AccountPreferenceScreenArgument argument;

  const HyppeAccountPreferences({Key? key, required this.argument})
      : super(key: key);

  @override
  _HyppeAccountPreferencesState createState() =>
      _HyppeAccountPreferencesState();
}

class _HyppeAccountPreferencesState extends State<HyppeAccountPreferences>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    final notifier =
        Provider.of<AccountPreferencesNotifier>(context, listen: false);
    Future.delayed(
        Duration.zero, () => notifier.onInitial(context, widget.argument));
    _tabController = TabController(
        initialIndex: notifier.initialIndex, length: 2, vsync: this);

    

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: WillPopScope(
          onWillPop: notifier.onWillPop,
          child: DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: CustomTextWidget(
                  textToDisplay: notifier.language.accountPreferences!,
                  textStyle: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                      (kToolbarHeight - 10) * SizeConfig.scaleDiagonal),
                  child: Container(
                    padding: const EdgeInsets.only(top: 10),
                    color: Theme.of(context).backgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                              color: Theme.of(context).tabBarTheme.labelColor!,
                              width: 2.0)),
                      labelColor: Theme.of(context).tabBarTheme.labelColor,
                      labelPadding: const EdgeInsets.only(bottom: 10.0),
                      unselectedLabelColor:
                          Theme.of(context).tabBarTheme.unselectedLabelColor,
                      labelStyle: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w400,
                          fontSize: 16 * SizeConfig.scaleDiagonal),
                      physics: const BouncingScrollPhysics(),
                      unselectedLabelStyle: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w400,
                          fontSize: 16 * SizeConfig.scaleDiagonal),
                      tabs: [
                        Text(notifier.language.profile!),
                        Text(notifier.language.personalInformation!),
                      ],
                    ),
                  ),
                ),
                titleSpacing: 0,
                leading: IconButton(
                  icon: const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}back-arrow.svg"),
                  splashRadius: 1,
                  onPressed: () {
                    notifier.initialIndex = 0;
                    Routing().moveBack();
                  },
                ),
              ),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: SizeConfig.screenHeight! -
                      ((kToolbarHeight +
                              ((kToolbarHeight - 10) *
                                  SizeConfig.scaleDiagonal)) *
                          SizeConfig.scaleDiagonal),
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      BuildProfileBody(),
                      BuildPersonalInformationBody(),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10),
                child: ButtonAccountPreferences(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
