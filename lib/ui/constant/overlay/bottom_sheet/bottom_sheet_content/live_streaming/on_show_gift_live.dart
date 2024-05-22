import 'package:flutter_svg/flutter_svg.dart';
import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_loading.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:provider/provider.dart';

class OnShowGiftLiveBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final String? idViewStream;
  const OnShowGiftLiveBottomSheet({Key? key, required this.scrollController, this.idViewStream}) : super(key: key);

  @override
  State<OnShowGiftLiveBottomSheet> createState() => _OnShowGiftLiveBottomSheetState();
}

class _OnShowGiftLiveBottomSheetState extends State<OnShowGiftLiveBottomSheet> {
  PageController? controller = PageController();
  bool firstTab = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreamerNotifier>().getGift(context, mounted, 'CLASSIC');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentMethodNotifier>(
      builder: (context, notifier, __) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * SizeConfig.scaleDiagonal),
            child: const CustomIconWidget(iconData: "${AssetPath.vectorPath}handler.svg", defaultColor: false),
          ),
          _tab(),
          Expanded(
              child: PageView.builder(
            controller: controller,
            itemCount: 2,
            onPageChanged: (value) {
              firstTab = (value == 0);
              setState(() {});
              if (value == 1) {
                context.read<StreamerNotifier>().getGift(context, mounted, 'DELUXE');
              }
            },
            itemBuilder: (context, index) {
              if (index == 1) {
                return _classic(false);
              }
              return _classic(true);
            },
          )),
          _saldo(),
        ],
      ),
    );
  }

  Widget _classic(bool isClassic) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<StreamerNotifier>(
      builder: (_, sn, __) {
        var data = isClassic ? sn.dataGift : sn.dataGiftDeluxe;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: sn.isloadingGift
              ? Padding(
                  padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
                  child: const SizedBox(
                    height: 100,
                    width: 100,
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomLoading(
                        size: 6,
                      ),
                    ),
                  ),
                )
              : data.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          trans.emptyGift ?? 'Gift stock will be available shortly, stay tuned! ✨',
                          style: const TextStyle(color: kHyppeBurem),
                        ),
                      ),
                    )
                  : GridView.builder(
                      itemCount: isClassic ? sn.dataGift.length : sn.dataGiftDeluxe.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      controller: widget.scrollController,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1 / 1,
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context2, index) {
                        var data = isClassic ? sn.dataGift[index] : sn.dataGiftDeluxe[index];
                        final mimeType = System().extensionFiles(data.thumbnail ?? '')?.split('/')[0] ?? '';
                        String type = '';
                        if (mimeType != '') {
                          var a = mimeType.split('/');
                          type = a[0];
                        }

                        return GestureDetector(
                          onTap: () {
                            sn.giftSelect = data;
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xfffbfbfb),
                              border: Border.all(color: (sn.giftSelect?.sId ?? '') == data.sId ? kHyppePrimary : kHyppeBorderTab, width: (sn.giftSelect?.sId ?? '') == data.sId ? 2 : 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Text("asd $type"),
                                // CustomIconWidget(iconData: iconData)
                                type == '.svg'
                                    ? SvgPicture.network(
                                        data.thumbnail ?? '',
                                        // 'https://www.svgrepo.com/show/1615/nurse.svg',
                                        height: 30 * SizeConfig.scaleDiagonal,
                                        width: 30 * SizeConfig.scaleDiagonal,
                                        // semanticsLabel: 'A shark?!',
                                        // color: false,
                                        placeholderBuilder: (BuildContext context) => Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                                      )
                                    // ? SvgPicture.asset(
                                    //     '${AssetPath.vectorPath}test.svg',
                                    //     height: 30,
                                    //     width: 30,
                                    //     semanticsLabel: 'A shark?!',
                                    //     placeholderBuilder: (BuildContext context) => Container(padding: const EdgeInsets.all(30.0), child: const CircularProgressIndicator()),
                                    //   )
                                    : SizedBox(
                                        // width: MediaQuery.of(context2).size.width,
                                        width: 30 * SizeConfig.scaleDiagonal,
                                        height: 30 * SizeConfig.scaleDiagonal,
                                        child: CustomCacheImage(
                                          imageUrl: data.thumbnail ?? '',
                                          imageBuilder: (_, imageProvider) {
                                            return Container(
                                              alignment: Alignment.topRight,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                              ),
                                            );
                                          },
                                          errorWidget: (_, __, ___) {
                                            return Container(
                                              alignment: Alignment.topRight,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(2),
                                                image: const DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                                ),
                                              ),
                                            );
                                          },
                                          emptyWidget: Container(
                                            alignment: Alignment.topRight,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              image: const DecorationImage(
                                                fit: BoxFit.contain,
                                                image: AssetImage('${AssetPath.pngPath}content-error.png'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                Text(
                                  "${data.name}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: kHyppeBurem, fontSize: 12),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CustomIconWidget(
                                      height: 15,
                                      iconData: "${AssetPath.vectorPath}ic-coin.svg",
                                      defaultColor: false,
                                    ),
                                    sixPx,
                                    Text(
                                      '${data.price}',
                                      style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _tab() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!firstTab) {
                  controller!.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    firstTab = true;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: firstTab ? kHyppePrimary : kHyppeBurem, width: 2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Classic',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 14,
                          color: firstTab ? kHyppePrimary : kHyppeBurem,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (firstTab) {
                  controller!.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    firstTab = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: !firstTab ? kHyppePrimary : kHyppeBurem, width: 2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Deluxe',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 14,
                          color: !firstTab ? kHyppePrimary : kHyppeBurem,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saldo() {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              const CustomIconWidget(
                height: 20,
                iconData: "${AssetPath.vectorPath}ic-coin.svg",
                defaultColor: false,
              ),
              sixPx,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trans.ballance}: 200',
                    style: const TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700),
                  ),
                  sixPx,
                  RichText(
                    text: TextSpan(
                      text: '${trans.toBeUsed} : ',
                      style: const TextStyle(
                        color: kHyppeBurem,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '50 Coins',
                          style: TextStyle(color: kHyppeTextLightPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.only(top: 6, bottom: 6, left: 16, right: 12),
                decoration: BoxDecoration(color: kHyppeTextLightPrimary, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Text(
                      'Top Up',
                      style: TextStyle(color: Colors.white),
                    ),
                    CustomIconWidget(
                      iconData: "${AssetPath.vectorPath}arrow_right.svg",
                      defaultColor: false,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
          twelvePx,
          Consumer<StreamerNotifier>(
            builder: (_, sn, __) {
              return ButtonChallangeWidget(
                function: () {
                  sn.sendGift(context, mounted, sn.giftSelect?.sId ?? '', sn.giftSelect?.thumbnail ?? '', sn.giftSelect?.name ?? '',
                      urlGift: sn.giftSelect?.animation, idViewStream: widget.idViewStream);
                },
                bgColor: kHyppePrimary,
                text: trans.send,
              );
            },
          )
        ],
      ),
    );
  }
}
