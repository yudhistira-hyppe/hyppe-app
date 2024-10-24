import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/entities/report/notifier.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';

class OnReportAccountBottomSheet extends StatefulWidget {
  final ContentData? postData;
  final String? type;
  final bool inDetail;
  final Function? onUpdate;

  const OnReportAccountBottomSheet({
    Key? key,
    this.type,
    this.postData,
    this.inDetail = true,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<OnReportAccountBottomSheet> createState() => _OnReportAccountBottomSheetState();
}

class _OnReportAccountBottomSheetState extends State<OnReportAccountBottomSheet> {
  Map<String, int> report = {};
  // int _currentReport = 1;
  // static final _routing = Routing();
  BuildContext? scaffoldContext;

  @override
  void initState() {
    final notifier = context.read<ReportNotifier>();
    notifier.initializeData(context);
    notifier.currentReport = '';
    notifier.currentReportDesc = '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    scaffoldContext = context;
    final _textTheme = Theme.of(context).textTheme;

    return Consumer2<ReportNotifier, TranslateNotifierV2>(
      builder: (context, notifier, translate, child) => SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                color: const Color(0xffF5F5F5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        textToDisplay: widget.type == 'block' ? "${translate.translate.blockThisAccount}" : "${translate.translate.reportThisAccount}",
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
                  child: notifier.loadingOption
                      ? SizedBox(
                          height: SizeConfig.screenHeight ?? 0 / 1.2,
                          child: const CustomLoading(),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const SizedBox(
                              //   height: 20,
                              // ),
                              // CustomTextWidget(
                              //   textToDisplay: translate.translate.whyareyoureportingthiscontent ?? '',
                              //   textStyle: Theme.of(context).primaryTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              // ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: notifier.initData?.data.length ?? 0,
                                itemBuilder: (context, index) {
                                  return RadioListTile<String>(
                                    contentPadding: const EdgeInsets.all(0),
                                    groupValue: notifier.initData?.data[index].sId ?? '',
                                    value: notifier.currentReport,
                                    onChanged: (_) {
                                      setState(() {
                                        notifier.currentReport = notifier.initData?.data[index].sId ?? '';
                                        notifier.currentReportDesc = notifier.initData?.data[index].description ?? '';
                                      });
                                    },
                                    toggleable: true,
                                    title: CustomTextWidget(
                                      textAlign: TextAlign.left,
                                      textToDisplay: notifier.titleLang(notifier.initData?.data[index].reason ?? '', notifier.initData?.data[index].reasonEn ?? ''),
                                      textStyle: Theme.of(context).primaryTextTheme.titleSmall,
                                      maxLines: 2,
                                    ),
                                    controlAffinity: ListTileControlAffinity.trailing,
                                    activeColor: Theme.of(context).colorScheme.primary,
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
                                    Routing().moveBack();
                                    Routing().moveBack();
                                    if (widget.type == 'block') {
                                      ShowBottomSheet().onShowColouredSheet(context, "Thanks for letting us know",
                                          subCaption: "You will not see content post from this user anymore. It will take at most 1 hour before all content from this user are hidden from you..");
                                    } else {
                                      ShowBottomSheet().onShowColouredSheet(context, "Thanks for letting us know", subCaption: "Your feedback will help us to improve your experience.");
                                    }
                                  },
                                  child: notifier.isLoading
                                      ? const CustomLoading()
                                      : CustomTextWidget(
                                          textToDisplay: translate.translate.submit ?? '',
                                          textStyle: _textTheme.bodyText2?.copyWith(color: kHyppeLightButtonText),
                                        )),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
