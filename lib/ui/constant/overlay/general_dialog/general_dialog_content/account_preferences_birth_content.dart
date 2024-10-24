import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';

class AccountPreferencesBirthContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountPreferencesNotifier>(
      builder: (_, notifier, __) => SizedBox(
        height: SizeConfig.screenHeight! * 0.6,
        width: SizeConfig.screenWidth,
        child: Center(
          child: CupertinoTheme(
            data: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            child: CupertinoDatePicker(
              initialDateTime: notifier.initialDateTime(),
              maximumDate: DateTime.now(),
              maximumYear: DateTime.now().year,
              minimumDate: DateTime(1900, 01, 01),
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (DateTime v) => notifier
                  .dateOfBirthSelected(DateFormat("yyyy-MM-dd").format(v)),
            ),
          ),
        ),
      ),
    );
  }
}
