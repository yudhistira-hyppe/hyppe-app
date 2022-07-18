import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<PaymentMethodNotifier>(
      builder: (_, notifier, __) => Scaffold(
        appBar: AppBar(
          leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
          leading: CustomIconButtonWidget(
            defaultColor: true,
            iconData: "${AssetPath.vectorPath}back-arrow.svg",
            onPressed: () => Routing().moveBack(),
          ),
          titleSpacing: 0,
          title: CustomTextWidget(
            textToDisplay: notifier.language.payment!,
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                  textToDisplay: notifier.language.totalPayment!,
                  textStyle: textTheme.titleMedium),
              const SizedBox(height: 5),
              CustomTextWidget(
                textToDisplay: "Rp 15.000",
                textStyle: textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primaryVariant),
              ),
              const SizedBox(height: 24),
              CustomTextWidget(
                  textToDisplay: "Virtual Account",
                  textStyle: textTheme.bodyMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(children: [
                  listBank(image: "bank_bca.png"),
                  listBank(image: "bank_mandiri.png"),
                  listBank(image: "bank_bni.png"),
                  listBank(
                      image: "other_bank.png",
                      title: notifier.language.seeOtherBank!,
                      bg: false,
                      isLast: true),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listBank(
      {String image = "bank_bca.png",
      String title = "",
      bool isLast = false,
      bool bg = true}) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Routing().move(Routes.paymentBCAScreen),
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
                  padding: bg
                      ? const EdgeInsets.symmetric(vertical: 5, horizontal: 10)
                      : null,
                  child: Image.asset(
                    "${AssetPath.pngPath}$image",
                    width: 56 * SizeConfig.scaleDiagonal,
                    height: 20 * SizeConfig.scaleDiagonal,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomTextWidget(
                    textToDisplay: title, textStyle: textTheme.bodyMedium),
              ],
            ),
            const CustomIconWidget(
                iconData: "${AssetPath.vectorPath}chevron_right.svg"),
          ],
        ),
      ),
    );
  }
}
