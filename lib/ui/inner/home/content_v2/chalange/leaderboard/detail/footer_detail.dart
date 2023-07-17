import 'package:flutter/material.dart';
import 'package:hyppe/core/constants/size_config.dart';
import 'package:hyppe/core/constants/themes/hyppe_colors.dart';
import 'package:hyppe/core/services/system.dart';
import 'package:hyppe/initial/hyppe/translate_v2.dart';
import 'package:hyppe/ui/constant/widget/custom_spacer.dart';
import 'package:hyppe/ui/constant/widget/custom_text_widget.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/leaderboard/widget/button_challange.dart';
import 'package:hyppe/ui/inner/home/content_v2/chalange/notifier.dart';
import 'package:provider/provider.dart';

class FooterChallangeDetail extends StatelessWidget {
  const FooterChallangeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    var tn = context.read<TranslateNotifierV2>();

    return Consumer<ChallangeNotifier>(
      builder: (_, cn, __) {
        bool twoWidget = false;
        var challengeData = cn.leaderBoardData?.challengeData?[0];
        if (challengeData?.objectChallenge == "AKUN") {
          if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
            if ((challengeData?.metrik?[0].aktivitasAkun?[0].ikuti ?? 0) > 0 && (challengeData?.metrik?[0].aktivitasAkun?[0].referal ?? 0) > 0) {
              twoWidget = true;
            }
          }

          if (challengeData?.metrik?[0].interaksiKonten?.isNotEmpty ?? [].isEmpty) {
            if (((challengeData?.metrik?[0].interaksiKonten?[0].suka?.isNotEmpty ?? [].isEmpty) || (challengeData?.metrik?[0].interaksiKonten?[0].tonton?.isNotEmpty ?? [].isEmpty)) &&
                (challengeData?.metrik?[0].interaksiKonten?[0].buatKonten?.isNotEmpty ?? [].isEmpty)) {
              twoWidget = true;
            }
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            accountActivity(context, tn, cn),
            Divider(
              color: kHyppeLightSurface,
              thickness: twoWidget == true ? 4.0 : 0,
            ),
            twoWidget ? accountActivity(context, tn, cn, widgetTwo: true) : Container(),
          ],
        );
      },
    );
  }

  Widget accountActivity(BuildContext context, TranslateNotifierV2 tn, ChallangeNotifier cn, {bool widgetTwo = false}) {
    String titleText = "";
    String buttonText = "";
    bool referral = false;
    Color bgColor = kHyppePrimary;
    Color textColors = kHyppeLightButtonText;
    var challengeData = cn.leaderBoardData?.challengeData?[0];
    if (widgetTwo) {
      titleText = "Ikuti akun - akun TerhHyppe untuk memenangkan kompetisi";
      buttonText = "Jelajahi dan Ikuti Akun Terhyppe disini!";
    } else {
      if (challengeData?.objectChallenge == "AKUN") {
        if (challengeData?.metrik?[0].aktivitasAkun?.isNotEmpty ?? [].isEmpty) {
          if ((challengeData?.metrik?[0].aktivitasAkun?[0].referal ?? 0) > 0) {
            titleText = "Gabung dan undang temanmu ke Hyppe sekarang!";
            buttonText = "Lihat QR Kode";
            bgColor = kHyppeLightButtonText;
            textColors = kHyppePrimary;
            referral = true;
          } else {
            titleText = "Ikuti akun - akun TerhHyppe untuk memenangkan kompetisi";
            buttonText = "Jelajahi dan Ikuti Akun Terhyppe disini!";
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          twelvePx,
          referral
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: kHyppeLightSurface,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomTextWidget(
                          textToDisplay: 'https://xxx.xxx.xxx',
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: kHyppeLightSecondary,
                              ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => System().shareText(dynamicLink: 'https://xxx.xxx.xxx', context: context),
                          child: Container(
                            height: 24,
                            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(color: kHyppePrimary, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              tn.translate.copy ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
          ButtonChallangeWidget(
            text: buttonText,
            bgColor: bgColor,
            borderColor: kHyppePrimary,
            textColors: textColors,
          ),
        ],
      ),
    );
  }
}
