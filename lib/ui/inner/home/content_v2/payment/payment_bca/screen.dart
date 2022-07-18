import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_rich_text_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';

class PaymentBCAScreen extends StatefulWidget {
  const PaymentBCAScreen({Key? key}) : super(key: key);

  @override
  State<PaymentBCAScreen> createState() => _PaymentBCAScreenState();
}

class _PaymentBCAScreenState extends State<PaymentBCAScreen> {
  late List<bool> _isOpen;
  @override
  void initState() {
    super.initState();

    _isOpen = [false, false, false];
  }

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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(
                textToDisplay: "Total Payment",
                textStyle: textTheme.titleMedium),
            const SizedBox(height: 5),
            CustomTextWidget(
              textToDisplay: "Rp 15.000",
              textStyle: textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primaryVariant),
            ),
            const SizedBox(height: 24),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Image.asset(
                "${AssetPath.pngPath}bank_bca_large.png",
                width: 131 * SizeConfig.scaleDiagonal,
                height: 47 * SizeConfig.scaleDiagonal,
              ),
            ),
            const SizedBox(height: 14),
            CustomTextWidget(
                textToDisplay: "Make payment before",
                textStyle: textTheme.titleSmall!
                    .copyWith(color: Color.fromRGBO(201, 29, 29, 1))),
            CustomTextWidget(
                textToDisplay: "Saturday, 15 Jul 2022 01:50 WIB",
                textStyle: textTheme.titleSmall!
                    .copyWith(color: Color.fromRGBO(201, 29, 29, 1))),
            CustomTextWidget(
                textToDisplay: "00:14:30",
                textStyle: textTheme.titleSmall!
                    .copyWith(color: Color.fromRGBO(201, 29, 29, 1))),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CustomTextWidget(
                  textToDisplay: "BCA Virtual Account",
                  textStyle: textTheme.titleSmall),
            ),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("9091 0856 9500 6900"),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryVariant,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50))),
                      child: CustomTextWidget(
                          textToDisplay: "Salin",
                          textStyle: textTheme.titleSmall!
                              .copyWith(color: Colors.white)),
                    ),
                  ],
                )),
            Material(
              elevation: 0,
              child: ExpansionPanelList(
                dividerColor: Colors.transparent,
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text("Via ATM"),
                          ],
                        ),
                      );
                    },
                    body: Text("Now open"),
                    isExpanded: _isOpen[0],
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text("Via m-BCA"),
                          ],
                        ),
                      );
                    },
                    body: Text("Now open"),
                    isExpanded: _isOpen[1],
                  ),
                  ExpansionPanel(
                    headerBuilder: (context, isOpen) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Text("Via KlikBCA Individual"),
                          ],
                        ),
                      );
                    },
                    body: Text("Now open"),
                    isExpanded: _isOpen[2],
                  )
                ],
                expansionCallback: (i, isOpen) =>
                    setState(() => _isOpen[i] = !isOpen),
              ),
            )
          ],
        ),
      ),
    );
  }
}
