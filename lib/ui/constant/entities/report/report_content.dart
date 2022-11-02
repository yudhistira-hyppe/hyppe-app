import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class ReportContentScreen extends StatefulWidget {
  final ContentData? postData;
  final String? type;
  const ReportContentScreen({Key? key, this.postData, this.type}) : super(key: key);

  @override
  State<ReportContentScreen> createState() => _ReportContentScreenState();
}

class _ReportContentScreenState extends State<ReportContentScreen> {
  Map<String, int> report = {};
  int _currentReport = 1;
  static final _routing = Routing();
  BuildContext? scaffoldContext;

  @override
  void initState() {
    final translate = context.read<TranslateNotifierV2>().translate;
    super.initState();
    report = {
      "${translate.spam}": 1,
      "${translate.nudityOrSexualActivity}": 2,
      "${translate.hateSpeechOrSymbols}": 3,
      "${translate.violanceOrDangerousOrganizations}": 4,
      "${translate.bullyingOrHarassment}": 5,
      "${translate.fakeOrMisleadingInformation}": 6,
      "${translate.selfHarmSuicideOrDangerousActs}": 7,
      "${translate.scamOrFraud}": 8,
      "${translate.illegalActivitiesAndRegulatedGoods}": 9,
      "${translate.intellectualProperty}": 10,
      "${translate.falseorMisleadingInformation}": 11,
      "${translate.extremeViolence}": 12,
      "${translate.other}": 13
    };
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    scaffoldContext = context;
    final _textTheme = Theme.of(context).textTheme;
    return Consumer<TranslateNotifierV2>(
      builder: (context, notifier, child) => SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xffF5F5F5),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.translate.reportThisContent ?? '',
                            textStyle: Theme.of(context).primaryTextTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context, true);
                              },
                              child: const Icon(Icons.close))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          CustomTextWidget(
                            textToDisplay: notifier.translate.whyareyoureportingthiscontent ?? '',
                            textStyle: Theme.of(context).primaryTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: report.length,
                            itemBuilder: (context, index) {
                              return RadioListTile<int>(
                                contentPadding: const EdgeInsets.all(0),
                                groupValue: report.values.toList()[index],
                                value: _currentReport,
                                onChanged: (_) {
                                  setState(() {
                                    _currentReport = report.values.toList()[index];
                                  });
                                },
                                toggleable: true,
                                title: CustomTextWidget(
                                  textAlign: TextAlign.left,
                                  textToDisplay: report.keys.toList()[index],
                                  textStyle: Theme.of(context).primaryTextTheme.titleSmall,
                                  maxLines: 2,
                                ),
                                controlAffinity: ListTileControlAffinity.trailing,
                                activeColor: Theme.of(context).colorScheme.primaryVariant,
                              );
                            },
                          ),
                          tenPx,
                          CustomElevatedButton(
                            width: SizeConfig.screenWidth,
                            height: 50,
                            buttonStyle: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                                overlayColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                                foregroundColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                                shadowColor: MaterialStateProperty.all<Color>(kHyppePrimary)),
                            function: () {
                              context.read<ReportNotifier>().reportPost(context).whenComplete(() => Navigator.pop(context, true));

                              // _showMessage("Your feedback will help us to improve your experience.");
                              // _showMessage("Thanks for letting us know", "We will review your report. If we find this content is violating of our community guidelines we will take action on it.");
                            },
                            child: Selector<UserInterestNotifier, bool>(
                              selector: (context, notifier) => notifier.isLoading,
                              builder: (_, value, __) {
                                return CustomTextWidget(
                                  textToDisplay: notifier.translate.report ?? '',
                                  textStyle: _textTheme.bodyText2?.copyWith(color: kHyppeLightButtonText),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(
    String message,
    String desc,
  ) {
    // show message
    _routing.showSnackBar(
      snackBar: SnackBar(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: SafeArea(
          child: SizedBox(
            height: 86,
            child: OnColouredSheet(
              maxLines: 3,
              caption: message,
              subCaption: desc,
              fromSnackBar: true,
              textOverflow: TextOverflow.visible,
            ),
          ),
        ),
        backgroundColor: kHyppeTextSuccess,
      ),
    );
  }
}
