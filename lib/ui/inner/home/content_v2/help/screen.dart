import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/faq_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/after_first_layout_mixin.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_search_bar.dart';
import 'package:hyppe/ui/constant/widget/custom_shimmer.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import '../../../../../core/arguments/ticket_argument.dart';
import '../../../../constant/widget/no_result_found.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with AfterFirstLayoutMixin {
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'HelpScreen');
    TranslateNotifierV2().startLoadingFAQ();
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
            textStyle: Theme.of(context).textTheme.titleMedium,
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
                textStyle: Theme.of(context)
                    .primaryTextTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              CustomSearchBar(
                hintText: notifier.translate.searchtopic,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 16 * SizeConfig.scaleDiagonal),
                onSubmitted: (value) {
                  notifier.getListOfFAQ(context, category: value);
                },
              ),
              if (!notifier.isLoading)
                GestureDetector(
                  onTap: () async {
                    Routing().move(Routes.ticketHistory,
                        argument:
                            TicketArgument(values: notifier.onProgressTicket));
                  },
                  child: Container(
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
                          textToDisplay:
                              notifier.translate.yourTicketIssue ?? '',
                          textStyle:
                              Theme.of(context).primaryTextTheme.bodySmall,
                          textAlign: TextAlign.start,
                        ),
                        const Spacer(),
                        const CustomIconWidget(
                          iconData: "${AssetPath.vectorPath}chevron_right.svg",
                        ),
                      ],
                    ),
                  ),
                ),
              twentyFourPx,
              CustomTextWidget(
                textToDisplay:
                    notifier.translate.frequentlyAskedQuestions ?? '',
                textStyle:
                    Theme.of(context).primaryTextTheme.bodyLarge?.copyWith(),
              ),
              eightPx,
              Expanded(
                child: Container(
                  child: !notifier.isLoading
                      ? notifier.listFAQ.isNotEmpty
                          ? ListView.builder(
                              itemCount: notifier.listFAQ.length,
                              itemBuilder: (context, index) {
                                for (var data
                                    in notifier.listFAQ[index].detail) {
                                  print('data details : ${data.toJson()}');
                                }

                                return GestureDetector(
                                    onTap: () {
                                      Routing().move(Routes.faqDetail,
                                          argument: FAQArgument(
                                              details: notifier
                                                  .listFAQ[index].detail));
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10, right: 10),
                                        child: Text(
                                            notifier.listFAQ[index].kategori ??
                                                '')));
                              })
                          : const NoResultFound()
                      : ListView.builder(
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return Container(
                                margin: const EdgeInsets.only(
                                    bottom: 10, right: 10),
                                child: const CustomShimmer(
                                  width: double.infinity,
                                  height: 25,
                                  radius: 8,
                                ));
                          }),
                ),
              ),
              if (!notifier.isLoading)
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black.withOpacity(0.12),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: context.isDarkMode()
                        ? Colors.black12
                        : const Color(0xffFBFBFB),
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
                                textToDisplay:
                                    notifier.translate.stillNeedsHelp ?? '',
                                maxLines: 2,
                                textAlign: TextAlign.start,
                              ),
                              (notifier.onProgressTicket.length < 10 &&
                                      !System().isGuest())
                                  ? CustomTextButton(
                                      onPressed: () {
                                        // notifier.navigateToBankAccount();
                                        Routing()
                                            .moveAndPop(Routes.supportTicket);
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  kHyppePrimary)),
                                      child: CustomTextWidget(
                                        textToDisplay: notifier
                                                .translate.submitTicketIssue ??
                                            '',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    )
                                  : CustomTextButton(
                                      onPressed: () {},
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  kHyppeLightInactive1)),
                                      child: CustomTextWidget(
                                        textToDisplay: notifier
                                                .translate.submitTicketIssue ??
                                            '',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: kHyppeGrey),
                                      ),
                                    ),
                            ]),
                      ),
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
