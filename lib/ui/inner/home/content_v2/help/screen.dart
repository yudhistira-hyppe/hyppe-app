import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/faq_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with AfterFirstLayoutMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    TranslateNotifierV2().getListOfFAQ(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (context, notifier, child) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: '${notifier.translate.help}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                textToDisplay: notifier.translate.helloCanIhelpyou ?? '',
                textStyle: Theme.of(context).primaryTextTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold),
              ),
              CustomSearchBar(
                hintText: notifier.translate.searchtopic,
                contentPadding: EdgeInsets.symmetric(vertical: 16 * SizeConfig.scaleDiagonal),
                onSubmitted: (value) {
                  notifier.getListOfFAQ(context, category: value);
                },
              ),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black.withOpacity(0.12),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}ticket.svg",
                    ),
                    tenPx,
                    CustomTextWidget(
                      textToDisplay: notifier.translate.yourTicketIssue ?? '',
                      textStyle: Theme.of(context).primaryTextTheme.caption,
                      textAlign: TextAlign.start,
                    ),
                    const Spacer(),
                    const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}chevron_right.svg",
                    ),
                  ],
                ),
              ),
              twentyFourPx,
              CustomTextWidget(
                textToDisplay: notifier.translate.frequentlyAskedQuestions ?? '',
                textStyle: Theme.of(context).primaryTextTheme.bodyText1?.copyWith(),
              ),
              eightPx,
              Expanded(
                child: Container(
                  child: notifier.listFAQ.isNotEmpty
                      ? ListView.builder(
                          itemCount: notifier.listFAQ.length,
                          itemBuilder: (context, index) {
                            for (var data in notifier.listFAQ[index].detail) {
                              print('data details : ${data.toJson()}');
                            }

                            return GestureDetector(
                                onTap: () {
                                  Routing().move(Routes.faqDetail, argument: FAQArgument(details: notifier.listFAQ[index].detail));
                                },
                                child: Container(width: double.infinity, margin: const EdgeInsets.only(top: 10, bottom: 10, right: 10), child: Text(notifier.listFAQ[index].kategori ?? '')));
                          })
                      : Center(
                          child: Text(notifier.translate.noData ?? 'No Data Found'),
                        ),
                ),
              ),

              // ...List.generate(
              //   supportNotifier.levelData.length,
              //   (index) => Padding(
              //       padding: const EdgeInsets.all(2.0),
              //       child: RadioListTile<String>(
              //         contentPadding: EdgeInsets.zero,
              //         groupValue: supportNotifier.nameLevel,
              //         value: supportNotifier.levelData[index].descLevel ?? '',
              //         onChanged: (val) {
              //           supportNotifier.nameLevel = val ?? '';
              //           supportNotifier.idLevelTicket = supportNotifier.levelData[index].sId ?? '';
              //         },
              //         toggleable: true,
              //         title: CustomTextWidget(
              //           textAlign: TextAlign.left,
              //           textToDisplay: supportNotifier.levelData[index].descLevel ?? '',
              //           textStyle: Theme.of(context).primaryTextTheme.bodyText2,
              //         ),
              //         subtitle: Text('The condition will appear if the users problem need technical   that can’t be solved by Guideline and will most likely be an improvement or new feature.'),
              //         controlAffinity: ListTileControlAffinity.leading,
              //         activeColor: Theme.of(context).colorScheme.primaryVariant,
              //         isThreeLine: true,
              //       )),
              // ),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black.withOpacity(0.12),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: context.isDarkMode() ? Colors.black12 : kHyppeLightSurface,
                ),
                child: Row(
                  children: [
                    const CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}customer-support.svg",
                      defaultColor: false,
                    ),
                    fortyPx,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.translate.stillNeedsHelp ?? '',
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                          CustomTextButton(
                            onPressed: () {
                              // notifier.navigateToBankAccount();
                              Routing().moveAndPop(Routes.supportTicket);
                            },
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                            child: CustomTextWidget(
                              textToDisplay: notifier.translate.submitTicketIssue ?? '',
                              textStyle: Theme.of(context).textTheme.button?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
