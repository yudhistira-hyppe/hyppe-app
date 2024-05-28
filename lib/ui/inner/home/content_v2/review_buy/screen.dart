import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/content_discount.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/size_widget.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/extension/utils_extentions.dart';
import 'package:hyppe/core/models/collection/posts/content_v2/content_data.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/icon_button_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/saldo_coin/saldo_coin.dart';
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
  bool isloading = true;
  bool buttonactive = false;

  @override
  void initState() {
    isloading = true;
    buttonactive = false;
    FirebaseCrashlytics.instance.setCustomKey('layout', 'ReviewBuyNotifier');
    var notifier = Provider.of<ReviewBuyNotifier>(context, listen: false);
    notifier.initState(context, widget.arguments);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 300),(){
        setState(() {
          isloading = false;
        });
      });
    });
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
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
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
                                image: (NetworkImage((widget.arguments?.isApsara ?? false) ? (widget.arguments?.mediaThumbEndPoint ?? '') : (widget.arguments?.fullThumbPath ?? ''))),
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
                          contentInfo(textTheme, title: notifier.language.certificateNumber ?? ' ', value: notifier.buyDataNew.nomorSertifikat ?? ''),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: SizedBox(
                              height: 1,
                              child: Container(color: Colors.black12),
                            ),
                          ),
                          contentInfo(textTheme, title: notifier.language.localeDatetime == 'id' ? 'Jenis Konten' : 'Content Type', value: System().convertTypeContent(notifier.buyDataNew.jenisKonten ?? '')),
                          contentInfo(textTheme, title: 'Creator', value: notifier.buyDataNew.creator ?? ''),
                          // contentInfo(textTheme, title: 'Creator', value: widget.arguments?.username ?? ''),
                          contentInfo(textTheme, title: notifier.language.time ?? '', value: notifier.data?.createdAt ?? ''),
                          // contentInfo(textTheme, title: notifier.language.time ?? '', value: notifier.buyDataNew.waktu ?? ''),
                          contentInfo(textTheme,
                              title: notifier.language.localeDatetime =='id'  ? 'Termasuk Total Dilihat' : 'Include Total Views', value: (notifier.buyDataNew.view ?? false) ? notifier.language.yes ?? 'yes' : notifier.language.no ?? 'no'),
                          contentInfo(textTheme,
                              title: notifier.language.localeDatetime =='id' ? 'Termasuk Total Suka' : 'Include Total Likes', value: (notifier.buyDataNew.like ?? false) ? notifier.language.yes ?? 'yes' : notifier.language.no ?? 'no'),
                          if (!(notifier.discount.checked??false))
                          const Divider(
                            thickness: .1,
                          ),
                          contentInfo(textTheme, title: notifier.language.sellingPrice ?? '', value: '${System().numberFormat(amount: notifier.buyDataNew.price?.toInt())} Coins'),
                          if (notifier.discount.checked??false)
                            Column(
                              children: [
                                const Divider(
                                  thickness: .1,
                                ),
                                contentInfo(textTheme, title: notifier.language.discount ?? '', value: '- ${System().numberFormat(amount: notifier.discount.nominal_discount)} Coins'),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 16),
                                        child: CustomTextWidget(
                                          textAlign: TextAlign.left,
                                          textToDisplay: notifier.language.localeDatetime == 'id' ? 'Total Biaya' : 'Total Cost',
                                          textStyle: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: CustomIconWidget(
                                                iconData: "${AssetPath.vectorPath}ic-coin.svg",
                                                height: 18,
                                                defaultColor: false,
                                              ),
                                            ),
                                            CustomTextWidget(
                                              textAlign: TextAlign.right,
                                              maxLines: 3,
                                              textToDisplay: System().numberFormat(amount: (notifier.buyDataNew.price?.toInt())! - (notifier.discount.nominal_discount??0)),
                                              textStyle: textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          
                          // contentInfo(textTheme, title: 'Service Fee (${notifier.data?.prosentaseAdminFee})', value: System().currencyFormat(amount: notifier.data?.adminFee?.toInt())),
                          // contentInfo(textTheme, title: "Admin Fee", value: System().currencyFormat(amount: notifier.data?.serviceFee?.toInt())),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamed(context, Routes.mydiscount, arguments: {'routes': Routes.reviewBuyContent, 'totalPayment': notifier.data?.price?.toInt(), 'discount': notifier.discount, 'productType': ContentDiscount.disccontentmarketplase});
                        isloading = true;
                        isloading = false;
                        // Future.delayed(const Duration(milliseconds: 300),() {
                        //   isloading = false;
                        // });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(width: .3, color: kHyppeBurem),
                          borderRadius: BorderRadius.circular(12.0),
                          color: kHyppeBurem.withOpacity(.03)
                        ),
                        child: ListTile(
                          minLeadingWidth: 10,
                          leading: const CustomIconWidget(
                            iconData: "${AssetPath.vectorPath}ic-kupon.svg",
                            defaultColor: false,
                          ),
                          title: (notifier.discount.checked??false) ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextWidget(textToDisplay: '${notifier.language.discount} ${System().currencyFormat(amount: notifier.discount.nominal_discount)}'),
                              CustomTextWidget(textToDisplay: notifier.discount.code_package??'', textStyle: const TextStyle(color: kHyppeBurem, fontWeight: FontWeight.w400),),
                            ],
                          ):Text(notifier.language.discountForYou ?? 'Diskon Untukmu'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    )
                  ],
                ),
              ),
        floatingActionButton: notifier.data != null
            ? Container(
                height: 110,
                // color: Theme.of(context).appBarTheme.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // if (!isloading)
                      AnimatedOpacity(
                        opacity: isloading ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: SaldoCoinWidget(
                          transactionCoin: notifier.buyDataNew.price! - (notifier.discount.nominal_discount??0),
                          isChecking: (bool val, int saldoCoin){
                            buttonactive = val;
                            setState(() { });
                          },
                        ),
                      ),
                      
                      twelvePx,
                      ElevatedButton(
                        onPressed: buttonactive 
                        ? () {
                          print('disini');
                        }
                        : null,
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor: kHyppePrimary),
                        child: SizedBox(
                          width: 375.0 * SizeConfig.scaleDiagonal,
                          height: 44.0 * SizeConfig.scaleDiagonal,
                          child: Center(
                            child: Text(notifier.language.buy ?? 'Beli', textAlign: TextAlign.center),
                          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CustomTextWidget(
              textAlign: TextAlign.left,
              textToDisplay: title,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(
            child: CustomTextWidget(
              textAlign: TextAlign.right,
              maxLines: 3,
              textToDisplay: value,
              textStyle: textTheme.caption?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
        ],
      ),
    );
  }
}
