import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/upload/review_sell/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ReviewSellContentScreen extends StatefulWidget {
  const ReviewSellContentScreen({Key? key}) : super(key: key);

  @override
  State<ReviewSellContentScreen> createState() =>
      _ReviewSellContentScreenState();
}

class _ReviewSellContentScreenState extends State<ReviewSellContentScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
        body: Container(
          child: Text("Papan"),
        ),
      ),
    );
  }
}
