import 'package:flutter/material.dart';
import 'package:hyppe/core/arguments/update_contents_argument.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/validate_type.dart';
import 'package:hyppe/ui/inner/upload/review_sell/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ReviewSellContentScreen extends StatefulWidget {
  final UpdateContentsArgument arguments;
  const ReviewSellContentScreen({Key? key, required this.arguments})
      : super(key: key);

  @override
  State<ReviewSellContentScreen> createState() =>
      _ReviewSellContentScreenState();
}

class _ReviewSellContentScreenState extends State<ReviewSellContentScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ReviewSellNotifier>(
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
            textToDisplay: notifier.language.orderSummary!,
            textStyle:
                Theme.of(context).textTheme.headline6!.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValidateType(editContent: widget.arguments.onEdit),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            contentInfo(textTheme,
                                title: "Type", value: "HyppePic"),
                            contentInfo(textTheme,
                                title: "Time", value: "27/07/2021 02:25 PM"),
                            contentInfo(textTheme,
                                title: "Ownership", value: "Registering"),
                            contentInfo(textTheme,
                                title: "Fee", value: "Rp 15.000"),
                            contentInfo(textTheme,
                                title: "Price", value: "Rp 10.000.000"),
                            contentInfo(textTheme,
                                title: "Views", value: "include"),
                            contentInfo(textTheme,
                                title: "Likes", value: "include"),
                            contentInfo(textTheme,
                                title: "OrderID", value: "12584295y2ce3c002"),
                          ],
                        )
                      ],
                    ),
                    subTotalBlock(textTheme, context),
                  ],
                ),
              ),
              paymentMethodsTitle(textTheme, context),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(
                  children: [
                    bankTile(
                        value: IntialBankSelect.vaBca,
                        selected: notifier.bankSelected,
                        onTap: (val) => notifier.bankSelected = val,
                        icon: "${AssetPath.vectorPath}bank_icon.svg",
                        title: "BCA Virtual Account",
                        hasBottomBorder: true),
                    bankTile(
                        value: IntialBankSelect.hyppeWallet,
                        selected: notifier.bankSelected,
                        onTap: (val) => notifier.bankSelected = val,
                        icon: "${AssetPath.vectorPath}logo.svg",
                        title: "Hyppe Wallet",
                        subtitle: "Balance Rp 10.000.000",
                        hasBottomBorder: false),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Container(
          height: 90,
          color: Theme.of(context).appBarTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      textToDisplay: "Total",
                      textStyle: textTheme.titleMedium,
                    ),
                    CustomTextWidget(
                      textToDisplay: "Rp 15.000",
                      textStyle: textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  width: 375.0 * SizeConfig.scaleDiagonal,
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  function: () => Routing().move(Routes.paymentScreen),
                  child: CustomTextWidget(
                    textToDisplay: "Proceed To Payment",
                    textStyle: textTheme.button
                        ?.copyWith(color: kHyppeLightButtonText),
                  ),
                  buttonStyle: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryVariant),
                    shadowColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryVariant),
                    overlayColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryVariant),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primaryVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget paymentMethodsTitle(TextTheme textTheme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: "Payment Methods",
            textStyle: textTheme.titleMedium,
          ),
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: "See All",
            textStyle: textTheme.labelLarge?.copyWith(color: kHyppePrimary),
          ),
        ],
      ),
    );
  }

  Widget subTotalBlock(TextTheme textTheme, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 145 * SizeConfig.scaleDiagonal,
            child: CustomTextWidget(
              textAlign: TextAlign.left,
              textToDisplay: "Subtotal",
              textStyle: textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: "Rp 15.000.000",
            textStyle: textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget contentInfo(TextTheme textTheme,
      {required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: 95 * SizeConfig.scaleDiagonal,
            child: CustomTextWidget(
              textAlign: TextAlign.left,
              textToDisplay: title,
              textStyle: textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: value,
            textStyle: textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget bankTile(
      {required IntialBankSelect value,
      required IntialBankSelect? selected,
      required void Function(IntialBankSelect?) onTap,
      required String icon,
      required String title,
      required bool hasBottomBorder,
      String? subtitle}) {
    return Container(
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
        title: CustomTextWidget(
          textToDisplay: title,
          textStyle: Theme.of(context).textTheme.subtitle2,
          textAlign: TextAlign.start,
          textOverflow: TextOverflow.clip,
        ),
        subtitle: subtitle != null
            ? CustomTextWidget(
                textToDisplay: subtitle,
                textStyle: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: kHyppeSecondary),
                textAlign: TextAlign.start,
                textOverflow: TextOverflow.clip,
              )
            : null,
        leading: Padding(
          padding: const EdgeInsets.only(top: 6),
          child:
              CustomIconWidget(iconData: icon, defaultColor: false, width: 16),
        ),
        trailing: Radio<IntialBankSelect>(
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
