import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/content/interest_user_overview_tile.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_button.dart';
import 'package:hyppe/ui/outer/sign_up/widget/sign_up_text.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/enum.dart';
import 'package:hyppe/core/services/error_service.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_error_widget.dart';

class InterestContent extends StatelessWidget {
  final bool fromSetting;
  final List<String> userInterested;
  const InterestContent({Key? key, required this.fromSetting, required this.userInterested}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<UserInterestNotifier>();
    final error = context.select((ErrorService value) => value.getError(ErrorType.getInterests));

    if (context.read<ErrorService>().isInitialError(error, notifier.interest.isEmpty ? null : notifier.interest.isEmpty)) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: SizedBox(
            height: 198,
            child: CustomErrorWidget(
              function: () => notifier.onGetInterest(context),
              errorType: ErrorType.getInterests,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: SizeConfig.screenHeight! * 0.15),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignUpText(
                title: "${notifier.language.whatIsYourInterest!}?",
                description: notifier.language.andWeKnowWhatToGive!,
              ),
              sixtyFourPx,
              InterestUserOverviewTile(),
            ],
          ),
          fortyEightPx,
          SignUpButton(
            withSkipButton: true,
            caption: fromSetting ? notifier.language.save : null,
            onTap: () => notifier.onTapInterestButton(context, fromSetting, userInterested),
            onSkipTap: fromSetting ? null : notifier.interestSkipButton(),
            textStyle: notifier.interestNextTextColor(context, userInterested),
            buttonColor: notifier.interestNextButtonColor(context, userInterested),
          ),
        ],
      ),
    );
  }
}
