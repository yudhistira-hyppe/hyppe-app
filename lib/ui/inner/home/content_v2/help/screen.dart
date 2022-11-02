import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
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

class _HelpScreenState extends State<HelpScreen> {
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
                // controller: notifier.searchController1,
                // onSubmitted: (v) => notifier.onSearchPost(context, value: v),
                // onPressedIcon: () => notifier.onSearchPost(context),
                // onTap: () => notifier.moveSearchMore(),
                // onTap: () => _scaffoldKey.currentState.openEndDrawer(),
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
              GestureDetector(onTap: () => Routing().move(Routes.faqDetail), child: Text('List FAQ')),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black.withOpacity(0.12),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: kHyppeLightSurface,
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
