import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class FAQdetailScreen extends StatelessWidget {
  const FAQdetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TranslateNotifierV2>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.subtitle1,
            textToDisplay: ' ${notifier.translate.help}',
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Using Expanded and Spacer"),
                    Text("Using Expanded and Spacer"), Text("Using Expanded and Spacer"),
                    Text("Using Expanded and Spacer"),
                    Spacer(), //defaults is flex:1
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomTextWidget(
                            textToDisplay: notifier.translate.doesThisHelpsyou!,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomTextButton(
                                onPressed: () {
                                  Routing().move(Routes.supportTicket);
                                },
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppeLightSurface)),
                                child: CustomTextWidget(
                                  textToDisplay: notifier.translate.no!,
                                  textStyle: Theme.of(context).textTheme.button!.copyWith(color: kHyppePrimary),
                                ),
                              ),
                              sixPx,
                              CustomTextButton(
                                onPressed: () {
                                  // notifier.navigateToBankAccount();
                                },
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(kHyppePrimary)),
                                child: CustomTextWidget(
                                  textToDisplay: notifier.translate.yes!,
                                  textStyle: Theme.of(context).textTheme.button!.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
