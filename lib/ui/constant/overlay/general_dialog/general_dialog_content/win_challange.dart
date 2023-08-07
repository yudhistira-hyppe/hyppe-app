import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/ui/constant/widget/custom_convetti.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:hyppe/ux/path.dart';
import 'package:hyppe/ux/routing.dart';
import 'package:provider/provider.dart';

class WinChallangePop extends StatefulWidget {
  final String title;
  final String body;
  const WinChallangePop({Key? key, required this.body, required this.title}) : super(key: key);

  @override
  State<WinChallangePop> createState() => _WinChallangePopState();
}

class _WinChallangePopState extends State<WinChallangePop> {
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
                            "${AssetPath.pngPath}won.png",
                            height: 160,
                          ),
                          sixteenPx,
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF3E3E3E),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          sixteenPx,
                          Text(
                            widget.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9B9B9B),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          sixteenPx,
                          ButtonChallangeWidget(bgColor: kHyppePrimary, text: "Lihat Daftar Kemenangan Kamu", function: () {}),
                          sixPx,
                          ButtonChallangeWidget(bgColor: Colors.white, textColors: kHyppePrimary, text: "Tutup", function: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomConvetti(),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          sixteenPx,
                          const SizedBox(
                            height: 160,
                          ),
                          sixteenPx,
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.transparent,
                              fontSize: 18,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          sixteenPx,
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.transparent,
                              fontSize: 14,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          sixteenPx,
                          ButtonChallangeWidget(
                              bgColor: kHyppePrimary,
                              text: "Lihat Daftar Kemenangan Kamu",
                              function: () {
                                Routing().moveBack();
                                Routing().move(Routes.chalengeAchievement);
                              }),
                          sixPx,
                          ButtonChallangeWidget(
                              bgColor: Colors.white,
                              textColors: kHyppePrimary,
                              text: "Tutup",
                              function: () {
                                Routing().moveBack();
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
