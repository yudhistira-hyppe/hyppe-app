import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/verification_id/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/inner/home/content_v2/account_preferences/notifier.dart';

class VerificationDate extends StatelessWidget {
  const VerificationDate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VerificationIDNotifier>(
      builder: (_, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomIconWidget(
            iconData: "${AssetPath.vectorPath}handler.svg",
            defaultColor: false,
            color: kHyppeRank2,
          ),
          sixteenPx,
          CustomTextWidget(
            textAlign: TextAlign.center,
            textToDisplay: notifier.language.selectDate ?? 'Select Date',
            textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(fontSize: 18),
          ),
          SizedBox(
            height: SizeConfig.screenHeight! * 0.4,
            width: SizeConfig.screenWidth,
            child: Center(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                child: CupertinoDatePicker(
                    initialDateTime: notifier.selectedBirthDate,
                    maximumDate: DateTime.now(),
                    maximumYear: DateTime.now().year,
                    minimumDate: DateTime(1900, 01, 01),
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (DateTime v) {
                      // notifier.dateOfBirthSelected(DateFormat("yyyy-MM-dd").format(v));
                      notifier.selectedBirthDate = v;
                    }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomElevatedButton(
              height: 50,
              width: SizeConfig.screenWidth,
              buttonStyle: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              function: () => Routing().moveBack(),
              child: CustomTextWidget(
                textToDisplay: 'Save',
                textStyle: Theme.of(context).textTheme.button?.copyWith(color: kHyppeLightButtonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
