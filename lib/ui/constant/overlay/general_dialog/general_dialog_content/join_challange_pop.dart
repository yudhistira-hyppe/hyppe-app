import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_convetti.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class JoinChallangePop extends StatefulWidget {
  const JoinChallangePop({
    Key? key,
  }) : super(key: key);

  @override
  State<JoinChallangePop> createState() => _JoinChallangePopState();
}

class _JoinChallangePopState extends State<JoinChallangePop> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Consumer<ChallangeNotifier>(
      builder: (_, notifier, __) => GestureDetector(
        onTap: () {
          Routing().moveBack();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            sixteenPx,
                            Image.asset(
                              "${AssetPath.pngPath}comingsoon.png",
                              height: 160,
                            ),
                            sixteenPx,
                            const Text(
                              'Berhasil Mengikuti Challenge',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF3E3E3E),
                                fontSize: 18,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            sixteenPx,
                            const Text(
                              'Raih peringkat pertama dengan mengikuti\nkompetisi yang seru ini, yuk!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 14,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            sixteenPx,
                            ButtonChallangeWidget(bgColor: kHyppePrimary, text: "Tingkatkan Poinmu Sekarang", function: () {}),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            CustomConvetti(),
            CustomConvetti(),
            CustomConvetti(),
          ],
        ),
      ),
    );
  }
}
