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
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/widget/validate_type.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ReviewBuyContentScreen extends StatefulWidget {
  const ReviewBuyContentScreen({Key? key}) : super(key: key);

  @override
  State<ReviewBuyContentScreen> createState() => _ReviewBuyContentScreenState();
}

class _ReviewBuyContentScreenState extends State<ReviewBuyContentScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ReviewBuyNotifier>(
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
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                            "Penonton histeris saat pentolan group band ABC naik ke atas panggung #musicasik #fyp")),
                    SizedBox(width: 10),
                    Container(
                      alignment: Alignment.topRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        image: DecorationImage(
                          scale: 1,
                          image: NetworkImage(
                              "https://i.pinimg.com/originals/d9/56/9b/d9569bbed4393e2ceb1af7ba64fdf86a.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      width: 48 * SizeConfig.scaleDiagonal,
                      height: 48 * SizeConfig.scaleDiagonal,
                      child: Center(
                        child: CustomIconWidget(
                          defaultColor: false,
                          iconData: '${AssetPath.vectorPath}pause.svg',
                          width: 24 * SizeConfig.scaleDiagonal,
                          height: 24 * SizeConfig.scaleDiagonal,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Column(
                  children: [
                    contentInfo(textTheme,
                        title: "Order Number", value: "12912596495"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        height: 1,
                        child: Container(color: Colors.black12),
                      ),
                    ),
                    contentInfo(textTheme, title: "Type", value: "HyppePic"),
                    contentInfo(textTheme,
                        title: "Time", value: "27/07/2021 02:25 PM"),
                    contentInfo(textTheme, title: "Fee", value: "Rp 15.000"),
                    contentInfo(textTheme,
                        title: "Price", value: "Rp 10.000.000"),
                    contentInfo(textTheme,
                        title: "Include Total Views", value: "No"),
                    contentInfo(textTheme,
                        title: "Include Total Likes", value: "No"),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          height: 80,
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
                      textStyle: textTheme.titleSmall,
                    ),
                    CustomTextWidget(
                      textToDisplay: "Rp 15.000",
                      textStyle: textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  width: 375.0 * SizeConfig.scaleDiagonal,
                  height: 44.0 * SizeConfig.scaleDiagonal,
                  function: () => Routing().move(Routes.paymentMethodScreen),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: true,
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
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: title,
            textStyle: textTheme.bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          CustomTextWidget(
            textAlign: TextAlign.right,
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
