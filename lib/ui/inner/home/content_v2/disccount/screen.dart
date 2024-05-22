import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/core/bloc/monetization/disc/state.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/review_buy/notifier.dart';
import 'package:hyppe/ui/inner/home/widget/loadmore.dart';
import 'package:hyppe/ui/inner/upload/pre_upload_content/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../paymentcoin/notifier.dart';
import 'notifier.dart';
import 'widgets/coupon_widget.dart';
import 'widgets/error_widget.dart';
import 'widgets/shimmer_widget.dart';

class MyCouponsPage extends StatefulWidget {
  const MyCouponsPage({super.key});

  @override
  State<MyCouponsPage> createState() => _MyCouponsPageState();
}

class _MyCouponsPageState extends State<MyCouponsPage> {
  LocalizationModelV2? lang;
  final ScrollController scrollController = ScrollController();
  bool isHideButton = true;
  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'kupondiskonsaya');
    lang = context.read<TranslateNotifierV2>().translate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var notifier =  Provider.of<DiscNotifier>(context, listen: false);
      Map res = ModalRoute.of(context)!.settings.arguments as Map;
      if (res['routes'] != null){
        notifier.isView = res['routes']== Routes.saldoCoins;
        setState(() {
          isHideButton = notifier.isView;
        });
      }

      if (res['productType'] != null){
        notifier.productType = res['productType'];
      }else{
        notifier.productType = '';
      }
      
      if (res['totalPayment'] != null){
        notifier.totalPayment = res['totalPayment'];
      }

      notifier.initDisc(context);

    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscNotifier>(
      builder: (context, notifier, _) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
              onPressed: () => Routing().moveBack(),
              icon: const Icon(Icons.arrow_back_ios)),
          title: CustomTextWidget(
            textStyle: Theme.of(context).textTheme.titleMedium,
            textToDisplay: lang?.mycoupons ?? 'Kupon diskon saya',
          ),
        ),
        body: Consumer<DiscNotifier>(builder: (context, notifier, _) {
          if ((notifier.bloc.dataFetch.dataState == DiscState.init ||
              notifier.bloc.dataFetch.dataState == DiscState.loading) && !notifier.isLoadMore) {
            return const ContentLoader();
          } else if (notifier.bloc.dataFetch.dataState ==
              DiscState.getNotInternet) {
            return ErrorCouponsWidget(lang: lang,);
          } else {
            return RefreshLoadmore(
                scrollController: scrollController,
                isLastPage: notifier.isLastPage,
                noMoreWidget: Container(),
                onRefresh: () async {
                  await notifier.initDisc(context);
                },
                onLoadmore: () async {
                  if (!notifier.isLastPage){
                    notifier.isLastPage = false;
                    notifier.isLoadMore = true;
                    notifier.page++;
                    Future.microtask(() => notifier.loadMore(context));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    notifier.result.length + 1,
                    (index) {
                      if (index == 0){
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                          child: CustomTextWidget(textToDisplay: lang?.discountForYou ?? 'Diskon Untukmu',
                            textStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        boxShadow: [
                          BoxShadow(
                            color: kHyppeBurem.withOpacity(.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TicketWidget(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 6.5,
                        isCornerRounded: true,
                        padding: const EdgeInsets.all(12),
                        child: CouponWidget(
                            data: notifier.result[index -1 ], lang: lang,
                            allenable: notifier.productType == '',
                            ),
                      ),
                    );
                    }
                  ),
                ),
              );
          }
        }),
        bottomNavigationBar: isHideButton 
        ? const SizedBox.shrink()
        : Container(
          margin: const EdgeInsets.symmetric(vertical: 22, horizontal: 18.0),
          height: kToolbarHeight,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              Map res = ModalRoute.of(context)!.settings.arguments as Map;
              if (res['routes'] != null){
                switch (res['routes'] ) {
                  case Routes.paymentCoins:
                    context.read<PaymentCoinNotifier>().discount = notifier.result.firstWhere((element) => element.checked == true);
                    await context.read<PaymentCoinNotifier>().initCoinPurchaseDetail(context); 
                    break;

                  case Routes.reviewBuyContent:
                    if (!mounted) return;
                    context.read<ReviewBuyNotifier>().discount = notifier.result.firstWhere((element) => element.checked == true);
                    await context.read<ReviewBuyNotifier>().detailBuyData(context);
                    break;
                  
                  case '${Routes.preUploadContent}ownership':
                    if (!mounted) return;
                    context.read<PreUploadContentNotifier>().discountOwnership = notifier.result.firstWhere((element) => element.checked == true);
                    break;
                  case '${Routes.preUploadContent}boostpost':
                    if (!mounted) return;
                    context.read<PreUploadContentNotifier>().discountBoost = notifier.result.firstWhere((element) => element.checked == true);
                    break;
                  default:
                }

              }
              
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              backgroundColor: kHyppePrimary
            ),
            child: Center(
                child: Text(lang?.apply??'Terapkan',
                    textAlign: TextAlign.center,),
              ),
          ),
        ),
      ),
    );
  }
}
