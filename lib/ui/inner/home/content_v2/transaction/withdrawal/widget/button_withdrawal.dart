import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class ButtonWithdrawalWidget extends StatelessWidget {
  LocalizationModelV2? translate;
  ButtonWithdrawalWidget({Key? key, this.translate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth,
      height: 50,
      child: CustomTextButton(
        onPressed: () {
          Routing().move(Routes.withdrawalSummary);
        },
        // onPressed: notifier.checkSave()
        //     ? () {
        //         notifier.confirmAddBankAccount(context);
        //       }
        //     : null,
        // style: ButtonStyle(backgroundColor: notifier.checkSave() ? MaterialStateProperty.all(kHyppePrimary) : MaterialStateProperty.all(kHyppeDisabled)),
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
        child: CustomTextWidget(
          textToDisplay: translate!.next!,
          textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppeLightButtonText),
        ),
      ),
    );
  }
}
