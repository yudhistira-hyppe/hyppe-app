import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment/payment_summary/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaymentSummaryScreen extends StatefulWidget {
  const PaymentSummaryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  @override
  void initState() {
    var nn = Provider.of<PaymentSummaryNotifier>(context, listen: false);
    nn.initState(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Consumer<PaymentSummaryNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.payment!,
            textStyle: Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Theme(
          data: theme,
          child: notifier.bankData == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(textToDisplay: notifier.language.paymentBefore!, textStyle: textTheme.bodyMedium),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextWidget(
                            // textToDisplay: "Saturday, 15 Jul 2022 01:50 WIB",
                            textToDisplay: DateFormat('EEEE, dd MMM yyyy HH:mm', 'en_US').format(DateTime.parse(notifier.paymentMethodNotifier.postResponse!.expiredtimeva!)),
                            textStyle: textTheme.bodyMedium,
                          ),
                          CustomTextWidget(
                            textToDisplay: notifier.durationString,
                            textStyle: textTheme.bodyLarge!.copyWith(color: const Color.fromRGBO(201, 29, 29, 1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomTextWidget(textToDisplay: notifier.paymentMethodNotifier.postResponse!.bank!, textStyle: textTheme.bodyMedium),
                            Image(width: 77 * SizeConfig.scaleDiagonal, image: NetworkImage(notifier.bankData!.bankIcon!))
                          ],
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(notifier.paymentMethodNotifier.postResponse!.nova!),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: notifier.paymentMethodNotifier.postResponse!.nova!));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notifier.language.vaCopyToClipboard!)));
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryVariant, borderRadius: const BorderRadius.all(Radius.circular(50))),
                                  child: CustomTextWidget(textToDisplay: notifier.language.copy!, textStyle: textTheme.titleSmall!.copyWith(color: Colors.white)),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomTextWidget(textToDisplay: notifier.language.totalPayment!, textStyle: textTheme.bodyMedium!.copyWith(color: const Color.fromRGBO(115, 115, 115, 1))),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomTextWidget(textToDisplay: System().currencyFormat(amount: notifier.paymentMethodNotifier.postResponse!.totalamount), textStyle: textTheme.titleMedium),
                      const SizedBox(
                        height: 32,
                      ),
                      CustomTextWidget(textToDisplay: notifier.language.seePaymentInstruction!, textStyle: textTheme.bodyMedium!.copyWith(color: const Color.fromRGBO(115, 115, 115, 1))),
                      expansionLists(context, textTheme, 'Via ATM', notifier.bankData!.atm!),
                      expansionLists(context, textTheme, 'Via Internet Banking', notifier.bankData!.internetBanking!),
                      expansionLists(context, textTheme, 'Via m-Banking', notifier.bankData!.mobileBanking!),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        color: Theme.of(context).backgroundColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomElevatedButton(
                              width: SizeConfig.screenWidth,
                              height: 44.0 * SizeConfig.scaleDiagonal,
                              function: () => Routing().moveAndRemoveUntil(Routes.lobby, Routes.lobby),
                              child: CustomTextWidget(
                                textToDisplay: notifier.language.backToHome!,
                                textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                              ),
                              buttonStyle: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                                shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                                overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => Routing().move(Routes.transaction),
                                child: Text(
                                  notifier.language.checkPaymentStatus!,
                                  style: textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget expansionLists(BuildContext context, TextTheme textTheme, String title, String body) {
    if (body == '') {
      return Container();
    } else {
      return ExpansionTile(
        childrenPadding: EdgeInsets.zero,
        tilePadding: EdgeInsets.zero,
        textColor: kHyppeTextLightPrimary,
        iconColor: kHyppeTextLightPrimary,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: RichText(text: TextSpan(text: body, style: textTheme.bodyMedium!.copyWith(height: 1.5)), textAlign: TextAlign.left),
          )
        ],
      );
    }
  }
}
