import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/payment_summary/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/shared_preference_keys.dart';
import '../../../../../core/services/shared_preference.dart';

class PaymentBoostSummaryScreen extends StatefulWidget {
  const PaymentBoostSummaryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentBoostSummaryScreen> createState() => _PaymentBoostSummaryScreenState();
}

class _PaymentBoostSummaryScreenState extends State<PaymentBoostSummaryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    var nn = Provider.of<PaymentBoostSummaryNotifier>(context, listen: false);
    nn.initState(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    final translate = context.read<TranslateNotifierV2>().translate;

    initializeDateFormatting('id', null);
    return Consumer<PaymentBoostSummaryNotifier>(
      builder: (_, notifier, __) => WillPopScope(
        onWillPop: () async {
          notifier.paymentMethodNotifier.clearUpAndBackToHome(context);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
            leading: CustomIconButtonWidget(
              defaultColor: true,
              iconData: "${AssetPath.vectorPath}back-arrow.svg",
              onPressed: () {
                notifier.paymentMethodNotifier.clearUpAndBackToHome(context);
              },
            ),
            titleSpacing: 0,
            title: CustomTextWidget(
              textToDisplay: translate.payment ?? '',
              textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
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
                        CustomTextWidget(textToDisplay: translate.paymentBefore ?? '', textStyle: textTheme.bodyMedium),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextWidget(
                              // textToDisplay: "Saturday, 15 Jul 2022 01:50 WIB",
                              textToDisplay: DateFormat('EEEE, dd MMM yyyy HH:mm', notifier.language.localeDatetime).format(DateTime.parse(notifier.paymentMethodNotifier.boostPaymentResponse?.expiredtimeva ?? '')),
                              textStyle: textTheme.bodyMedium,
                            ),
                            TweenAnimationBuilder<Duration>(
                                duration: const Duration(minutes: 15),
                                tween: Tween(begin: const Duration(minutes: 15), end: Duration.zero),
                                onEnd: () {
                                  // notifier.backHome();
                                },
                                builder: (BuildContext context, Duration value, Widget? child) {
                                  final minutes = value.inMinutes;
                                  final seconds = value.inSeconds % 60;
                                  return CustomTextWidget(
                                    textToDisplay: '( ${minutes < 10 ? '0' : ''}$minutes: ${seconds < 10 ? '0' : ''}$seconds )',
                                    textStyle: textTheme.bodyLarge?.copyWith(color: const Color.fromRGBO(201, 29, 29, 1), fontWeight: FontWeight.bold),
                                  );
                                }),
                            // CustomTextWidget(
                            //   textToDisplay: notifier.durationString,
                            //   textStyle: textTheme.bodyLarge.copyWith(color: const Color.fromRGBO(201, 29, 29, 1)),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomTextWidget(textToDisplay: notifier.paymentMethodNotifier.boostPaymentResponse?.bank ?? '', textStyle: textTheme.bodyMedium),
                              Image(width: 77 * SizeConfig.scaleDiagonal, image: NetworkImage(notifier.bankData?.bankIcon ?? ''))
                            ],
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(notifier.paymentMethodNotifier.boostPaymentResponse?.nova ?? ''),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: notifier.paymentMethodNotifier.boostPaymentResponse?.nova ?? ''));
                                    ShowBottomSheet().onShowColouredSheet(_, translate.vaCopyToClipboard ?? '', maxLines: 2, color: kHyppeTextLightPrimary);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryVariant, borderRadius: const BorderRadius.all(Radius.circular(50))),
                                    child: CustomTextWidget(textToDisplay: translate.copy ?? 'copy', textStyle: textTheme.titleSmall?.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomTextWidget(textToDisplay: translate.totalPayment ?? 'total payment', textStyle: textTheme.bodyMedium?.copyWith(color: const Color.fromRGBO(115, 115, 115, 1))),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextWidget(textToDisplay: System().currencyFormat(amount: notifier.paymentMethodNotifier.boostPaymentResponse?.totalamount), textStyle: textTheme.titleMedium),
                        const SizedBox(
                          height: 32,
                        ),
                        CustomTextWidget(textToDisplay: translate.seePaymentInstruction ?? '', textStyle: textTheme.bodyMedium?.copyWith(color: const Color.fromRGBO(115, 115, 115, 1))),
                        expansionLists(context, textTheme, 'Via ATM', notifier.bankData?.atm ?? ''),
                        expansionLists(context, textTheme, 'Via m-Banking', notifier.bankData?.mobileBanking ?? ''),
                        expansionLists(context, textTheme, 'Via Internet Banking', notifier.bankData?.internetBanking ?? ''),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          color: Theme.of(context).backgroundColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomElevatedButton(
                                width: SizeConfig.screenWidth,
                                height: 44.0 * SizeConfig.scaleDiagonal,
                                function: () {
                                  notifier.paymentMethodNotifier.clearUpAndBackToHome(context);
                                },
                                child: CustomTextWidget(
                                  textToDisplay: translate.backToHome ?? '',
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
                                  onTap: () {
                                    context.read<PreUploadContentNotifier>().navigateToTransAndLoby(context);
                                  },
                                  child: Text(
                                    translate.checkPaymentStatus ?? '',
                                    style: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
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
            child: Html(
                data: body,
                style: {"a": Style(color: kHyppePrimary, textDecoration: TextDecoration.underline, textDecorationThickness: 0)},
                onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, element) async {
                  print(url);
                  if (await canLaunchUrl(Uri.parse(url ?? ''))) {
                    await launchUrl(
                      Uri.parse(url ?? ''),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    throw "Could not launch $url";
                  }
                }),
          )
        ],
      );
    }
  }
}
