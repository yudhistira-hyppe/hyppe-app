import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/bottom_sheet_content/on_coloured_sheet.dart';
import 'package:hyppe/ui/inner/home/content_v2/vid/notifier.dart';
import 'package:hyppe/ui/outer/sign_up/contents/user_interest/user_interest_notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class OnReportContentFormBottomSheet extends StatefulWidget {
  const OnReportContentFormBottomSheet({Key? key}) : super(key: key);

  @override
  State<OnReportContentFormBottomSheet> createState() => _OnReportContentFormBottomSheetState();
}

class _OnReportContentFormBottomSheetState extends State<OnReportContentFormBottomSheet> {
  Map<String, int> report = {};
  int _currentReport = 1;
  static final _routing = Routing();
  BuildContext? scaffoldContext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    report = {
      "I am not interested in this post": 1,
      "I have seen to many post in on this topic": 2,
      "I've seen too many post from this author": 3,
      "I've seen this post before": 4,
      "This post is old": 5,
    };
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    scaffoldContext = context;
    final _textTheme = Theme.of(context).textTheme;
    return Consumer<PreviewVidNotifier>(
      builder: (context, notifier, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xffF5F5F5),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            textToDisplay: 'Dont want to see this',
                            textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context, true);
                              },
                              child: Icon(Icons.close))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextWidget(
                    textToDisplay: "Tell us why you don't want to see this",
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
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
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        activeColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ],
              ),
              CustomElevatedButton(
                width: SizeConfig.screenWidth,
                height: 50,
                buttonStyle: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                    overlayColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                    foregroundColor: MaterialStateProperty.all<Color>(kHyppePrimary),
                    shadowColor: MaterialStateProperty.all<Color>(kHyppePrimary)),
                function: () {
                  print('asd');
                  Navigator.pop(context, true);

                  // _showMessage("Your feedback will help us to improve your experience.");
                  _showMessage(" Thanks for letting us know", "Your feedback will help us to improve your experience.");
                },
                child: Selector<UserInterestNotifier, bool>(
                  selector: (context, notifier) => notifier.isLoading,
                  builder: (_, value, __) {
                    return CustomTextWidget(
                      textToDisplay: 'Submit',
                      textStyle: _textTheme.bodyText2!.copyWith(color: kHyppeLightButtonText),
                    );
                  },
                ),
              ),
            ],
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
            height: 56,
            child: OnColouredSheet(
              maxLines: 2,
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
