import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:provider/provider.dart';

class PauseLiveView extends StatelessWidget {
  const PauseLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final tn = context.read<TranslateNotifierV2>().translate;
    return Container(
      // padding: const EdgeInsets.only(bottom: 100),
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Siaran LIVE dijeda',
                      // tn.liveBroadcastIsPausedViewersCannotCurrentlySeeYou ?? 'Siaran LIVE dijeda, penonton saat ini tidak dapat melihatmu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sixteenPx,
                    Text(
                      'Host akan segera kembali',
                      // tn.theLiveBroadcastWillEndAfterTheCountdown ?? 'Siaran LIVE akan berakhir setelah hitung mundur',
                      style: TextStyle(
                        color: kHyppeBurem,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    sixteenPx,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
