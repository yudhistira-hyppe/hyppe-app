import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:provider/provider.dart';

import 'package:hyppe/initial/hyppe/notifier.dart';

import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';

import 'package:hyppe/core/services/shared_preference.dart';

import 'package:hyppe/core/constants/themes/hyppe_theme.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  final _language = TranslateNotifierV2();
  bool _currentThemeState = false;

  Map<String, bool> themes = {};

  void _initThemes() {
    _currentThemeState = SharedPreference().readStorage(SpKeys.themeData) ?? false;
    themes = {"${_language.translate.dark}": true, "${_language.translate.light}": false};
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ThemeScreen');
    _initThemes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: CustomTextWidget(
          textToDisplay: "${_language.translate.theme}",
          textStyle: theme.textTheme.subtitle1,
        ),
      ),
      body: Consumer<HyppeNotifier>(
        builder: (_, notifier, __) {
          return ListView.builder(
            itemCount: themes.length,
            padding: const EdgeInsets.only(left: 16, top: 26),
            itemBuilder: (context, index) {
              return RadioListTile<bool>(
                groupValue: themes.values.toList()[index],
                value: _currentThemeState,
                onChanged: (_) {
                  _currentThemeState = themes.values.toList()[index];
                  notifier.themeData = _currentThemeState ? hyppeDarkTheme() : hyppeLightTheme();
                  SharedPreference().writeStorage(SpKeys.themeData, _currentThemeState);
                  System().systemUIOverlayTheme();
                },
                toggleable: true,
                title: CustomTextWidget(
                  textAlign: TextAlign.left,
                  textToDisplay: themes.keys.toList()[index],
                  textStyle: Theme.of(context).primaryTextTheme.bodyText1,
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            },
          );
        },
      ),
    );
  }
}
