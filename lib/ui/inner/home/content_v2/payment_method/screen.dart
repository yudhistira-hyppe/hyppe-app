import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/transaction_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/process_upload_component.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  final TransactionArgument? argument;
  const PaymentMethodScreen({Key? key, this.argument}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  void initState() {
    var nn = Provider.of<PaymentMethodNotifier>(context, listen: false);
    nn.initState(context);
    nn.bankSelected = '0';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<PaymentMethodNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * (SizeConfig.screenWidth ?? context.getWidth()) / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.paymentMethods ?? '',
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: notifier.data != null
            ? notifier.data?.isNotEmpty ?? false
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(textToDisplay: notifier.language.totalPayment ?? '', textStyle: textTheme.titleMedium),
                        const SizedBox(height: 5),
                        CustomTextWidget(
                          textToDisplay: widget.argument?.totalAmount != null
                              ? System().currencyFormat(amount: widget.argument?.totalAmount?.toInt())
                              : notifier.reviewBuyNotifier.data != null
                                  ? System().currencyFormat(amount: notifier.reviewBuyNotifier.data?.totalAmount?.toInt())
                                  : '',
                          textStyle: textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primaryVariant),
                        ),
                        const SizedBox(height: 24),
                        CustomTextWidget(textToDisplay: "Virtual Account", textStyle: textTheme.bodyMedium),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
                          child: Column(children: [
                            ..._getListBank(notifier),
                          ]),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  )
            : const Center(
                child: CircularProgressIndicator(),
              ),
        floatingActionButton: CustomElevatedButton(
          width: 375.0 * SizeConfig.scaleDiagonal,
          height: 44.0 * SizeConfig.scaleDiagonal,
          function: () {
            if (!notifier.isLoading) {
              notifier.submitPay(context, price: widget.argument?.totalAmount);
            }
          },
          // function: () => Routing().move(Routes.paymentSummaryScreen),
          child: notifier.isLoading
              ? const CustomLoading()
              : CustomTextWidget(
                  textToDisplay: widget.argument?.totalAmount != null ? "${notifier.language.upload} & ${notifier.language.pay}" : notifier.language.pay ?? 'pay',
                  textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                ),
          buttonStyle: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(notifier.colorButton(context)),
            shadowColor: MaterialStateProperty.all(notifier.colorButton(context)),
            overlayColor: MaterialStateProperty.all(notifier.colorButton(context)),
            backgroundColor: MaterialStateProperty.all(notifier.colorButton(context)),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget listBank({String image = "bank_bca.png", String title = "", bool isLast = false, bool bg = true}) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Routing().move(Routes.paymentSummaryScreen),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: !isLast
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 0.5,
                  ),
                ),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  color: bg ? Colors.white : Colors.transparent,
                  padding: bg ? const EdgeInsets.symmetric(vertical: 5, horizontal: 10) : null,
                  child: Image.asset(
                    "${AssetPath.pngPath}$image",
                    width: 56 * SizeConfig.scaleDiagonal,
                    height: 20 * SizeConfig.scaleDiagonal,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomTextWidget(textToDisplay: title, textStyle: textTheme.bodyMedium),
              ],
            ),
            const CustomIconWidget(iconData: "${AssetPath.vectorPath}chevron_right.svg"),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _getListBank(PaymentMethodNotifier notifier) {
    if (notifier.data != null && (notifier.data?.isNotEmpty ?? false)) {
      return notifier.data!.map((e) => bankTile(
            icon: e.bankIcon ?? '',
            title: e.bankname ?? '',
            hasBottomBorder: true,
            value: e.bankcode.toString(),
            selected: notifier.bankSelected,
            onTap: (val) => notifier.bankSelected = val ?? '',
          ));
    }
    return [];
  }

  Widget bankTile(
      {required String value, required String selected, required void Function(String?) onTap, required String icon, required String title, required bool hasBottomBorder, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: hasBottomBorder
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 0.5,
                ),
              ),
            )
          : null,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: CustomTextWidget(
          textToDisplay: title,
          textStyle: Theme.of(context).textTheme.subtitle2,
          textAlign: TextAlign.start,
          textOverflow: TextOverflow.clip,
        ),
        subtitle: subtitle != null
            ? CustomTextWidget(
                textToDisplay: subtitle,
                textStyle: Theme.of(context).textTheme.caption?.copyWith(color: kHyppeSecondary),
                textAlign: TextAlign.start,
                textOverflow: TextOverflow.clip,
              )
            : null,
        leading: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Image(
              image: NetworkImage(icon),
            )),
        trailing: Radio<String>(
          value: value,
          groupValue: selected,
          onChanged: onTap,
          activeColor: kHyppePrimary,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
