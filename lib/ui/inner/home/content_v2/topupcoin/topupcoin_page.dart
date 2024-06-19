import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hyppe/core/bloc/monetization/coin/state.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/models/collection/localization_v2/localization_model.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/overlay/bottom_sheet/show_bottom_sheet.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/constant/widget/section_widget.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

import 'notifier.dart';
import 'widgets/card_coin_widget.dart';
import 'widgets/coin_widget.dart';
import 'widgets/error_widget.dart';
import 'widgets/shimmer_widget.dart';

class TopUpCoinPage extends StatefulWidget {
  const TopUpCoinPage({super.key});

  @override
  State<TopUpCoinPage> createState() => _TopUpCoinPageState();
}

class _TopUpCoinPageState extends State<TopUpCoinPage> {
  LocalizationModelV2? lang;

  @override
  void initState() {
    FirebaseCrashlytics.instance.setCustomKey('layout', 'Top Up Hyppe Coins');
    lang = context.read<TranslateNotifierV2>().translate;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<TopUpCoinNotifier>().initCoin(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TopUpCoinNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            leading: IconButton(
                onPressed: () => Routing().moveBack(),
                icon: const Icon(Icons.arrow_back_ios)),
            title: CustomTextWidget(
              textStyle: theme.textTheme.titleMedium,
              textToDisplay: '${lang?.topupcoin}',
            ),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: CoinWidget(),
                  ),
                  SectionWidget(
                    title: lang?.buyhyppecoins??'Beli Hyppe Coins',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                  if (notifier.bloc.dataFetch.dataState == CoinState.init ||
                      notifier.bloc.dataFetch.dataState == CoinState.loading)
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: widgetGenerateLoading(),
                      )
                  else if (notifier.bloc.dataFetch.dataState == CoinState.getNotInternet)
                    Center(child: ErrorCouponsWidget(lang: lang,))
                  else
                    Wrap(
                      alignment: WrapAlignment.start,
                      children: widgetGenerate(notifier),
                    ),
                ],
              ),
            ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
            child: ElevatedButton(
              onPressed: notifier.result.where((e) => e.checked==true).isNotEmpty ? (){
                if ((notifier.result.firstWhere((e) => e.checked == true).last_stock??0) < 1){
                  var warning = lang?.localeDatetime == 'id' ? 'Maaf, paket Hyppe Coins yang kamu mau sudah habis. Lihat paket lainnya.' : 'Sorry, the Hyppe Coins package you want is out of stock. See other packages.';
                  FToast().init(context);
                    if (true) FToast().removeCustomToast();
                    FToast().showToast(
                      child: Container(
                        width: SizeConfig.screenWidth,
                        decoration: BoxDecoration(color: kHyppeBorderDanger, borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                            ),
                            twelvePx,
                            Expanded(
                                child: Text(
                              warning,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            )),
                          ],
                        ),
                      ),
                      gravity: ToastGravity.BOTTOM,
                      toastDuration: const Duration(seconds: 3),
                    );
                }else{
                  Navigator.pushNamed(context, Routes.paymentCoins, arguments: notifier.result.firstWhere((e) => e.checked==true));
                }
                
              }:null,
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  backgroundColor: kHyppePrimary),
              child: const SizedBox(
                width: double.infinity,
                height: kToolbarHeight,
                child: Center(
                  child: Text('Top Up', textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  List<Widget> widgetGenerateLoading() {
    List<Widget> widget = [];
    for (var i = 0; i < 10; i++) {
      Widget item = const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: ContentLoader()
      );
      widget.add(item);
    }
    return widget;
  }

  List<Widget> widgetGenerate(TopUpCoinNotifier notifier) {
    List<Widget> widget = [];
    for (var i = 0; i < notifier.result.length; i++) {
      Widget item = Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
        child: GestureDetector(
          onTap: (){
            notifier.changeSelectedCoin(notifier.result[i].id);
          },
          child: CardCoinWidget(
            coin: notifier.result[i].amount??0,
            coinlabel: notifier.result[i].price??0,
            selected: notifier.result[i].checked??false,
          ),
        ),
      );
      widget.add(item);
    }
    return widget;
  }
}
