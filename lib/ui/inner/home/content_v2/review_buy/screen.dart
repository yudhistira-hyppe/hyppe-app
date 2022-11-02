import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_elevated_button.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class ReviewBuyContentScreen extends StatefulWidget {
  final ContentData? arguments;
  const ReviewBuyContentScreen({Key? key, this.arguments}) : super(key: key);

  @override
  State<ReviewBuyContentScreen> createState() => _ReviewBuyContentScreenState();
}

class _ReviewBuyContentScreenState extends State<ReviewBuyContentScreen> {
  @override
  void initState() {
    var notifier = Provider.of<ReviewBuyNotifier>(context, listen: false);
    notifier.initState(context, widget.arguments);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ReviewBuyNotifier>(
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
            textToDisplay: notifier.language.orderSummary ?? '',
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: notifier.data == null
            ? const Center(child: CircularProgressIndicator(color: Colors.black54))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(child: Text(notifier.data?.description ?? '')),
                          const SizedBox(width: 10),
                          Container(
                            alignment: Alignment.topRight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              image: DecorationImage(
                                scale: 1,
                                // image: NetworkImage(System().showUserPicture('/pict/' + notifier.data.postId)),
                                image: NetworkImage(widget.arguments?.isApsara ?? false ? (widget.arguments?.mediaThumbEndPoint ?? '') : (widget.arguments?.fullThumbPath ?? '')),
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: 48 * SizeConfig.scaleDiagonal,
                            height: 48 * SizeConfig.scaleDiagonal,
                            child: notifier.data?.postType == 'vid'
                                ? Center(
                                    child: CustomIconWidget(
                                      defaultColor: false,
                                      iconData: '${AssetPath.vectorPath}pause.svg',
                                      width: 24 * SizeConfig.scaleDiagonal,
                                      height: 24 * SizeConfig.scaleDiagonal,
                                    ),
                                  )
                                : null,
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor, borderRadius: const BorderRadius.all(Radius.circular(8))),
                      child: Column(
                        children: [
                          contentInfo(textTheme, title: notifier.language.certificateNumber ?? '', value: notifier.data?.postId ?? ''),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              height: 1,
                              child: Container(color: Colors.black12),
                            ),
                          ),
                          contentInfo(textTheme, title: notifier.language.type ?? 'type', value: System().convertTypeContent(notifier.data?.postType ?? '')),
                          contentInfo(textTheme, title: System().capitalizeFirstLetter(notifier.language.from ?? 'from'), value: widget.arguments?.username ?? ''),
                          contentInfo(textTheme, title: notifier.language.time ?? '', value: notifier.data?.createdAt ?? ''),
                          contentInfo(textTheme, title: notifier.language.sellingPrice ?? '', value: System().currencyFormat(amount: notifier.data?.price?.toInt())),
                          contentInfo(textTheme, title: notifier.language.includeTotalViews ?? '', value: notifier.data?.saleView ?? false ? notifier.language.yes ?? 'yes' : notifier.language.no ?? 'no'),
                          contentInfo(textTheme, title: notifier.language.includeTotalLikes ?? '', value: notifier.data?.saleView ?? false ? notifier.language.yes ?? 'yes' : notifier.language.no ?? 'no'),
                          contentInfo(textTheme, title: 'Service Fee (${notifier.data?.prosentaseAdminFee})', value: System().currencyFormat(amount: notifier.data?.adminFee?.toInt())),
                          contentInfo(textTheme, title: "Admin Fee", value: System().currencyFormat(amount: notifier.data?.serviceFee?.toInt())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButton: notifier.data != null
            ? Container(
                height: 100,
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
                            textToDisplay: notifier.language.total ?? 'total',
                            textStyle: textTheme.titleSmall,
                          ),
                          CustomTextWidget(
                            textToDisplay: System().currencyFormat(amount: notifier.data?.totalAmount?.toInt()),
                            textStyle: Theme.of(context).primaryTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedButton(
                        width: 375.0 * SizeConfig.scaleDiagonal,
                        height: 44.0 * SizeConfig.scaleDiagonal,
                        function: () => Routing().move(Routes.paymentMethodScreen),
                        child: CustomTextWidget(
                          textToDisplay: notifier.language.choosePaymentMethods ?? '',
                          textStyle: textTheme.button?.copyWith(color: kHyppeLightButtonText),
                        ),
                        buttonStyle: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          shadowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          overlayColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                          backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: true,
      ),
    );
  }

  Widget contentInfo(TextTheme textTheme, {required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            textAlign: TextAlign.left,
            textToDisplay: title,
            textStyle: textTheme.caption?.copyWith(color: Theme.of(context).hintColor),
          ),
          CustomTextWidget(
            textAlign: TextAlign.right,
            textToDisplay: value,
            textStyle: textTheme.caption?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
