import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ux/routing.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50 * SizeConfig.screenWidth! / SizeWidget.baseWidthXD,
        leading: CustomIconButtonWidget(
          defaultColor: true,
          iconData: "${AssetPath.vectorPath}back-arrow.svg",
          onPressed: () => Routing().moveBack(),
        ),
        titleSpacing: 0,
        title: CustomTextWidget(
          textToDisplay: "Payment",
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
              child: Column(children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          "${AssetPath.pngPath}bank_bca.png",
                          width: 56 * SizeConfig.scaleDiagonal,
                          height: 20 * SizeConfig.scaleDiagonal,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomTextWidget(
                          textToDisplay: "BCA Virtual Account",
                          textStyle: textTheme.titleMedium),
                    ],
                  ),
                ),
                listPoint(context,
                    "This transaction will be automatically replace BCA Virtual Account bills which haven’t been paid."),
                SizedBox(
                  height: 10,
                ),
                listPoint(context, "Get booking code after tapping “Pay Now”")
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Row listPoint(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• "),
        SizedBox(
          width: 276 * SizeConfig.scaleDiagonal,
          child: CustomRichTextWidget(
            textAlign: TextAlign.start,
            textOverflow: TextOverflow.clip,
            textSpan: TextSpan(
              text: title,
              style: Theme.of(context).textTheme.caption?.copyWith(height: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
