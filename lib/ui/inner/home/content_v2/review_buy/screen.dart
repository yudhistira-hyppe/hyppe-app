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
                        title: notifier.language.orderNumber!,
                        value: "12912596495"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        height: 1,
                        child: Container(color: Colors.black12),
                      ),
                    ),
                    contentInfo(textTheme,
                        title: notifier.language.type!, value: "HyppePic"),
                    contentInfo(textTheme,
                        title: notifier.language.time!,
                        value: "27/07/2021 02:25 PM"),
                    contentInfo(textTheme, title: "Fee", value: "Rp 15.000"),
                    contentInfo(textTheme,
                        title: notifier.language.price!,
                        value: "Rp 10.000.000"),
                    contentInfo(textTheme,
                        title: notifier.language.includeTotalViews!,
                        value: "No"),
                    contentInfo(textTheme,
                        title: notifier.language.includeTotalLikes!,
                        value: "No"),
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
                      textToDisplay: notifier.language.total!,
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
                    textToDisplay: notifier.language.proceedPayment!,
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
}
