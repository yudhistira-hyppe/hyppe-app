import 'package:hyppe/core/constants/asset_path.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:flutter/material.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
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
    TranslateNotifierV2 lang = context.read<TranslateNotifierV2>();
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
                            Text(
                              lang.translate.successfulChallengeParticipation ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF3E3E3E),
                                fontSize: 18,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            sixteenPx,
                            Text(
                              lang.translate.getfirstplacebyentering ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9B9B9B),
                                fontSize: 14,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            sixteenPx,
                            ButtonChallangeWidget(bgColor: kHyppePrimary, text: "${lang.translate.increaseYourPointsNow}", function: () {}),
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
