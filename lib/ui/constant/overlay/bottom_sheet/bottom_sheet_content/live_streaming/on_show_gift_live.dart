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
import 'package:hyppe/ui/inner/home/content_v2/saldo_coin/saldo_coin.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/streamer/notifier.dart';
import 'package:hyppe/ui/inner/home/content_v2/video_streaming/view_streaming/notifier.dart';
import 'package:hyppe/ux/routing.dart';
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
  bool buttonactive = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewStreamingNotifier>().getGift(context, mounted, 'CLASSIC');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<ViewStreamingNotifier>(builder: (_, notifier, __) {
      if (notifier.isOver) {
        Navigator.pop(Routing.navigatorKey.currentContext!);
      }
      return Column(
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
                notifier.getGift(context, mounted, 'DELUXE');
              }
            },
            itemBuilder: (context, index) {
              if (index == 1) {
                return _classic(false);
              }
              return _classic(true);
            },
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: SaldoCoinWidget(
              transactionCoin: notifier.giftSelect?.price ?? 0,
              isChecking: (bool val, int saldoCoin) {
                notifier.saldoCoin = saldoCoin;
              },
            ),
          ),
          // Text("notifier.endLive ${notifier.isOver} ${buttonactive && !notifier.isOver}"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: ButtonChallangeWidget(
              function: () {
                if (notifier.buttonGift() && !notifier.isOver) {
                  notifier.sendGift(context, mounted, notifier.giftSelect?.sId ?? '', notifier.giftSelect?.thumbnail ?? '', notifier.giftSelect?.name ?? '',
                      urlGift: notifier.giftSelect?.animation, idViewStream: widget.idViewStream);
                }
              },
              bgColor: notifier.buttonGift() && !notifier.isOver ? kHyppePrimary : kHyppeDisabled,
              text: trans.send,
            ),
          ),
          twelvePx,
        ],
      );
    });
  }

  Widget _classic(bool isClassic) {
    var trans = context.read<TranslateNotifierV2>().translate;
    return Consumer<ViewStreamingNotifier>(
      builder: (_, sn, __) {
        var firstData = isClassic ? sn.dataGift : sn.dataGiftDeluxe;
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
              : firstData.isEmpty
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
                                        height: 44 * SizeConfig.scaleDiagonal,
                                        // width: 30 * SizeConfig.scaleDiagonal,
                                        fit: BoxFit.cover,
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
                                        width: 44 * SizeConfig.scaleDiagonal,
                                        height: 44 * SizeConfig.scaleDiagonal,
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
}
