import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_cache_image.dart';
import 'package:hyppe/ui/constant/widget/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/payment_method/notifier.dart';
import 'package:provider/provider.dart';

class OnShowGiftLiveBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  const OnShowGiftLiveBottomSheet({Key? key, required this.scrollController}) : super(key: key);

  @override
  State<OnShowGiftLiveBottomSheet> createState() => _OnShowGiftLiveBottomSheetState();
}

class _OnShowGiftLiveBottomSheetState extends State<OnShowGiftLiveBottomSheet> {
  PageController? controller = PageController();
  bool firstTab = true;

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
            },
            itemBuilder: (context, index) {
              if (index == 1) {
                return Container(
                  color: Colors.red,
                );
              }
              return _classic();
            },
          )),
          _saldo(),
        ],
      ),
    );
  }

  Widget _classic() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: 100,
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
          return Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xfffbfbfb),
              border: Border.all(color: kHyppeBorderTab),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  // width: MediaQuery.of(context2).size.width,
                  width: 30 * SizeConfig.scaleDiagonal,
                  height: 30 * SizeConfig.scaleDiagonal,
                  child: CustomCacheImage(
                    imageUrl: 'https://ahmadtaslimfuadi07.github.io/jsonlottie/image228.png',
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
                  "Lemper",
                  style: TextStyle(color: kHyppeBurem, fontSize: 12),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      height: 15,
                      iconData: "${AssetPath.vectorPath}ic-coin.svg",
                      defaultColor: false,
                    ),
                    sixPx,
                    Text(
                      '5',
                      style: TextStyle(color: kHyppeTextLightPrimary, fontWeight: FontWeight.w700),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
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
                    duration: Duration(milliseconds: 300),
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
                    duration: Duration(milliseconds: 300),
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
              Spacer(),
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
          ButtonChallangeWidget(
            bgColor: kHyppePrimary,
            text: trans.send,
          )
        ],
      ),
    );
  }
}
